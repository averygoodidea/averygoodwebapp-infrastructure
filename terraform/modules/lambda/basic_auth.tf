resource "random_string" "basic_auth" {
  length  = 4
  special = false
}

data "archive_file" "basic_auth" {
  type        = "zip"
  output_path = "tmp/basic_auth.zip"
  source {
    content = <<EOF
exports.handler = (event, context, callback) => {
  console.log('A', JSON.stringify(event.Records[0].cf))
  // basic auth script, for more information, visit - https://medium.com/hackernoon/serverless-password-protecting-a-static-website-in-an-aws-s3-bucket-bfaaa01b8666
  const { request } = event.Records[0].cf
  const host = request.headers.host[0].value
  const hostPieces = host.split('.')
  const environment = (hostPieces.length === 2) ? 'prod' : hostPieces[0]
  if (environment === 'prod') {
    console.log('B')
    callback(null, request)
  } else {
    console.log('C')
    // Get request headers
    const { headers } = request
    // Configure authentication
    // const authUser = '<authUser>'
    // const authPass = '<authPass>'
    // const authString = "Basic " + authUser + ":" + authPass
    // const authStrings = [
    //   "Basic " + authUser + ":" + authPass // share this authentication with others
    // ]
    const AWS = require('aws-sdk')
    AWS.config.update({region: "${var.region}" })
    const getAuthUsers = () => new Promise( async (resolve, reject) => {
      console.log('D')
      var params = {
          KeyConditionExpression: 'partitionKey = :partitionKey',
          ExpressionAttributeValues: {
              ':partitionKey': 'published'
          },
          TableName: "${var.basic_auth_table}"
      }
      console.log('E', params)
      try {
        const dynamo = new AWS.DynamoDB.DocumentClient()
        const data = await dynamo.query(params).promise()
        const authStrings = data.Items.map( ({ authUser, authPass }) => "Basic " + authUser + ":" + Buffer.from(authPass, 'base64').toString('ascii') )
        resolve(authStrings)
      } catch (err) {
        reject(err)
      }
    })
    let submitted
    const body = 'Unauthorized access.'
    const response = {
        status: '401',
        statusDescription: 'Unauthorized',
        body: body,
        headers: {
            'www-authenticate': [{key: 'WWW-Authenticate', value:'Basic'}]
        }
    }
    if (headers.authorization) {
      console.log('H')
      submitted = "Basic " + Buffer.from(headers.authorization[0].value.split('Basic ')[1], 'base64').toString('ascii')
      getAuthUsers().then( authStrings => {
        if (authStrings.includes(submitted)) {
          console.log('I')
          callback(null, request)
        } else {
          console.log('J')
          callback(null, response)
        }
      }).catch( err => {
        console.log('K', err)
        callback(null, response)
      })
    } else {
      console.log('L')
      callback(null, response)
    }
  }
}
EOF
  filename = "index.js"
  }
}

resource "aws_lambda_function" "basic_auth" {
  filename         = data.archive_file.basic_auth.output_path
  source_code_hash = filebase64sha256(data.archive_file.basic_auth.output_path)
  function_name    = "${var.namespace}-${var.environment}-${random_string.basic_auth.result}-BasicAuthLambdaEdge"
  role             = aws_iam_role.basic_auth.arn
  handler          = "index.handler"
  memory_size      = 128
  timeout          = 5
  runtime          = "nodejs10.x"
  publish          = true
}

resource "random_id" "basic_auth" {
  byte_length = 4
}

resource "aws_lambda_alias" "basic_auth" {
  name             = "${var.namespace}-${var.environment}-${random_id.basic_auth.id}-BasicAuthLambdaEdge-alias"
  function_name    = aws_lambda_function.basic_auth.function_name
  function_version = "$LATEST"
}

resource "aws_iam_role" "basic_auth" {
  name = "${var.namespace}-${var.environment}-${random_id.basic_auth.id}-BasicAuthLambdaEdge-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "basic_auth_AmazonDynamoDBReadOnlyAccess" {
  role       = aws_iam_role.basic_auth.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "basic_auth_AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.basic_auth.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "basic_auth_CloudFrontFullAccess" {
  role       = aws_iam_role.basic_auth.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}