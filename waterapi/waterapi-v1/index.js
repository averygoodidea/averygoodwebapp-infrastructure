const AWS = require('aws-sdk')
const { v4: uuidv4 } = require('uuid')
const slugid = require('slugid')
const moment = require('moment')
const axios = require('axios')
const { encrypt, decrypt, sendMagicLink } = require('./averygoodauthenticator')
const defaultTimeToLive = 60 * 60 * 24 * 365 // 365 days
const defaultResponse = {
    "statusCode": 200,
    "headers": {
        "Cache-Control": defaultTimeToLive,
        "Strict-Transport-Security": `max-age=${defaultTimeToLive}; includeSubDomains`,
        "X-Frame-Options": "SAMEORIGIN",
        "X-Content-Type-Options": "nosniff",
        "Referrer-Policy": "strict-origin",
        "Feature-Policy": "fullscreen 'none'; sync-xhr 'none'; speaker 'none'; microphone 'none'; camera 'none'; payment 'none'; geolocation 'none'; midi 'none'; notifications 'none'; push 'none'; magnetometer 'none'; gyroscope 'none'; vibrate 'none'",
        // generated using - https://report-uri.com/home/generate
        "Content-Security-Policy": "default-src 'self'",
        // CORS - Cross Origin Resource Sharing
        // Requires specific headers in a response to give browser requests that are validated, permission to execute.
        // more information can be found here:
        // https://www.authenticdesign.co.uk/understanding-cors-and-pre-flight/
        // PLEASE NOTE:
        // these headers need to be include in both the prefight response, and ALSO every other resource response, too.
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE",
        "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,x-requested-with",
        //"Access-Control-Allow-Origin": process.env.ACCESS_CONTROL_ALLOW_ORIGIN,
        "Access-Control-Allow-Credentials": "true"
        // more info on Access-Control-Allow-Credentials here:
        // -- https://stackoverflow.com/questions/24687313/what-exactly-does-the-access-control-allow-credentials-header-do
    },
    "isBase64Encoded": false
}

const GetFlightPermit = (callback) => {
    const response = Object.assign({}, defaultResponse)
    callback(null, response)
}

const GetAlbumPosts = async (event, callback) => {
    const response = Object.assign({}, defaultResponse)
    const {
        ALBUM_POSTS_TABLE
    } = process.env
    console.log('B')
    var params = {
        KeyConditionExpression: 'partitionKey = :partitionKey',
        ExpressionAttributeValues: {
            ':partitionKey': 'published'
        },
        TableName: ALBUM_POSTS_TABLE
    }
    const dynamo = new AWS.DynamoDB.DocumentClient()
    dynamo.query(params, (err, data) => {
        if (err) {
            responseBody = err
        } else {
            responseBody = data.Items
        }
        console.log('C', responseBody)
        response.body = JSON.stringify(responseBody)
        callback(null, response)
    })
}

const CreateAlbumPost = async (event, callback) => {
    //const response = Object.assign({}, defaultResponse)
    if(event.headers['Authorization']) {
        const { signInKey } = decrypt(JSON.parse(event.headers['Authorization']))
        event.queryStringParameters = Object.assign({}, event.queryStringParameters, {
            submittedKey: signInKey
        })
        VerifyHash(event, (error, response) => {
            console.log('C', response)
            if( response.statusCode === 200 ) {
                const {
                    ALBUM_POSTS_TABLE
                } = process.env
                const eventBody = decodeBase64(event.body)
                console.log('B', eventBody)
                try {
                    const keys = [
                        'title',
                        'summary',
                        'images',
                        'categories',
                        'moreInfoUrl'
                    ]
                    for (let i = 0; i < keys.length; i++) {
                        const param = eventBody[keys[i]]
                        if (!param || param.length === 0) {
                            throw `'${keys[i]}' parameter is required.`
                        }
                    }
                    const {
                        title,
                        summary,
                        images,
                        categories,
                        moreInfoUrl,
                        price
                    } = eventBody

                    let responseBody
                    var params = {
                        Item: {
                            partitionKey: 'published',
                            id: uuidv4(),
                            createdAt: getUnixTime(),
                            slugId: slugid.nice(),
                            title,
                            summary,
                            images,
                            categories,
                            moreInfoUrl
                        },
                        TableName: ALBUM_POSTS_TABLE
                    }
                    if (price && typeof price === 'number') {
                        params.Item.price = price
                    }
                    const dynamo = new AWS.DynamoDB.DocumentClient()
                    dynamo.put(params, (err, data) => {
                        if (err) {
                            responseBody = err
                        } else {
                            const { id, createdAt, slugId } = params.Item
                            responseBody = {
                                id,
                                createdAt,
                                slugId
                            }
                            const invalidationPaths = ['/api/1/album/posts']
                            invalidateCloudFrontCache(invalidationPaths, () => {
                                // call Gatsby Webhook to rebuild cloud application
                                triggerGatsbyWebhook()
                            })
                        }
                        console.log('C', responseBody)
                        response.body = JSON.stringify(responseBody)
                        callback(null, response)
                    })
                } catch (error) {
                    console.log('D')
                    response.statusCode = 400
                    response.body = JSON.stringify({ error })
                    console.log(error, response)
                    callback(null, response)
                }
            } else {
                // else will return error message
                console.log('F')
                callback(null, response)
            }
        })
    } else {
        console.log('G')
        const errorMessage = 'Unauthorized access.'
        response.statusCode = 401
        response.body = JSON.stringify({ error: errorMessage })
        console.log(errorMessage, response)
        callback(null, response)
    }
}

const UpdateAlbumPost = async (event, callback) => {
    //const response = Object.assign({}, defaultResponse)
    if(event.headers['Authorization']) {
        const { signInKey } = decrypt(JSON.parse(event.headers['Authorization']))
        event.queryStringParameters = Object.assign({}, event.queryStringParameters, {
            submittedKey: signInKey
        })
        VerifyHash(event, (error, response) => {
            console.log('C', response)
            if( response.statusCode === 200 ) {
                const {
                    ALBUM_POSTS_TABLE
                } = process.env
                console.log('B')
                const { id } = event.pathParameters
                var params = {
                    Key: {
                        'partitionKey': 'published',
                        id
                    },
                    TableName: ALBUM_POSTS_TABLE
                }
                const dynamo = new AWS.DynamoDB.DocumentClient()
                dynamo.get(params, (err, data) => {
                    if (err) {
                        console.log('C')
                        response.statusCode = err.statusCode
                        response.body = err.message
                        callback(null, response)
                    } else {
                        const { Item } = data
                        if (Item) {
                            console.log('D', data)
                            const {
                                title,
                                summary,
                                images,
                                categories,
                                price,
                                moreInfoUrl
                            } = decodeBase64(event.body)
                            let UpdateExpression
                            let ExpressionAttributeValues = {}
                            const preparePropToBeUpdated = (name, value) => {
                                if (!UpdateExpression) {
                                    UpdateExpression = `set ${name} = :${name}`
                                } else {
                                    UpdateExpression += `, ${name} = :${name}`
                                }
                                ExpressionAttributeValues[`:${name}`] = value
                            }
                            title && preparePropToBeUpdated('title', title)
                            summary && preparePropToBeUpdated('summary', summary)
                            images && preparePropToBeUpdated('images', images)
                            categories && preparePropToBeUpdated('categories', categories)
                            price && preparePropToBeUpdated('price', price)
                            moreInfoUrl && preparePropToBeUpdated('moreInfoUrl', moreInfoUrl)
                            console.log('E', UpdateExpression)
                            console.log('F', ExpressionAttributeValues)
                            params = {
                                Key: {
                                    'partitionKey': 'published',
                                    id
                                },
                                UpdateExpression,
                                ExpressionAttributeValues,
                                TableName: ALBUM_POSTS_TABLE
                            }
                            dynamo.update(params, (err, data) => {
                                if (err) {
                                    responseBody = err
                                } else {
                                    responseBody = JSON.stringify('success')
                                    const invalidationPaths = ['/api/1/album/posts']
                                    invalidateCloudFrontCache(invalidationPaths, () => {
                                        // call Gatsby Webhook to rebuild cloud application
                                        triggerGatsbyWebhook()
                                    })
                                }
                                console.log('G', params, responseBody)
                                response.body = JSON.stringify(responseBody)
                                callback(null, response)
                            })
                        } else {
                            console.log('H')
                            response.statusCode = 404
                            response.body = JSON.stringify("resource not found")
                            callback(null, response)
                        }
                    }
                })
            } else {
                // else will return error message
                console.log('F')
                callback(null, response)
            }
        })
    } else {
        console.log('G')
        const errorMessage = 'Unauthorized access.'
        response.statusCode = 401
        response.body = JSON.stringify({ error: errorMessage })
        console.log(errorMessage, response)
        callback(null, response)
    }
}

const DeleteAlbumPost = async (event, callback) => {
    //const response = Object.assign({}, defaultResponse)
    if(event.headers['Authorization']) {
        const { signInKey } = decrypt(JSON.parse(event.headers['Authorization']))
        event.queryStringParameters = Object.assign({}, event.queryStringParameters, {
            submittedKey: signInKey
        })
        VerifyHash(event, (error, response) => {
            console.log('C', response)
            if( response.statusCode === 200 ) {
                const {
                    ALBUM_POSTS_TABLE
                } = process.env
                console.log('B')
                const { id } = event.pathParameters
                var params = {
                    Key: {
                        'partitionKey': 'published',
                        id
                    },
                    TableName: ALBUM_POSTS_TABLE
                }
                const dynamo = new AWS.DynamoDB.DocumentClient()
                dynamo.get(params, (err, data) => {
                    if (err) {
                        console.log('C')
                        response.statusCode = err.statusCode
                        response.body = err.message
                        callback(null, response)
                    } else {
                        const { Item } = data
                        if (Item) {
                            console.log('D', data)
                            dynamo.delete(params, (err, data) => {
                                if (err) {
                                    response.body = JSON.stringify(err)
                                } else {
                                    response.statusCode = 204
                                    const invalidationPaths = ['/api/1/album/posts']
                                    invalidateCloudFrontCache(invalidationPaths, () => {
                                        // call Gatsby Webhook to rebuild cloud application
                                        triggerGatsbyWebhook()
                                    })
                                }
                                console.log('E', response)
                                callback(null, response)
                            })
                        } else {
                            console.log('F')
                            response.statusCode = 404
                            response.body = JSON.stringify("resource not found")
                            callback(null, response)
                        }
                    }
                })
            } else {
                // else will return error message
                console.log('F')
                callback(null, response)
            }
        })
    } else {
        console.log('G')
        const errorMessage = 'Unauthorized access.'
        response.statusCode = 401
        response.body = JSON.stringify({ error: errorMessage })
        console.log(errorMessage, response)
        callback(null, response)
    }
}

const RequestGraphQL = (event, context) => {
    console.log('B')
    const awsServerlessExpress = require('aws-serverless-express')
    const GraphQLApp = require('./graphql/app')
    const server = awsServerlessExpress.createServer(GraphQLApp)
    awsServerlessExpress.proxy(server, event, context)
}

// authenticate our admin
const SendAdminMagicLink = (event, callback) => {
    // if this email exists in the ADMIN_TABLE
        // send magic link to sign in
    // else
        // this ain't it, chief

    const response = Object.assign({}, defaultResponse)
    const { email, signInKey } = decodeBase64(event.body)
    console.log('B')
    // validate email
    if (isValidEmailFormat(email)) {
        if(signInKey) {
            // get admin email from ADMINS_TABLE
            // else
                // log error
            const {
                ALLOWED_MAGICLINK_URL,
                ADMINS_TABLE,
                SES_SENDER_EMAIL_ADDRESS
            } = process.env

            console.log('C')
            let params = {
                Key: {
                    'partitionKey': 'published',
                    email
                },
                TableName: ADMINS_TABLE
            }
            // update admin magic link key in ADMINS_TABLE
            const dynamo = new AWS.DynamoDB.DocumentClient()
            dynamo.get(params, (err, data) => {
                if (err) {
                    console.log('D')
                    response.statusCode = err.statusCode
                    response.body = err.message
                    callback(null, response)
                } else {

                    const { Item } = data
                    if (Item) {
                        console.log('E', data)
                        // send magic link to email address via SES
                        // and send response back with Authorization header
                        const hoursUntilExpiration = 24
                        const magicLink = `${ALLOWED_MAGICLINK_URL}/author/?signin=${signInKey}`
                        const emailData = {
                            from: SES_SENDER_EMAIL_ADDRESS,
                            to: email,
                            magicLink,
                            subject: `Your Magic Link to Sign In to AVeryGoodWebApp Will Expire in ${hoursUntilExpiration} Hours`,
                            body: `Sign in to AVeryGoodWebApp with your Magic Link below (the link expires in ${hoursUntilExpiration} hours).`
                        }
                        sendMagicLink(emailData, () => {
                            console.log('F', emailData)
                            const authData = {
                                signInKey,
                                email,
                                verificationStatus: 'unverified'
                            }
                            response.statusCode = 204
                            response.headers['Authorization'] = JSON.stringify(encrypt(authData, hoursUntilExpiration))
                            callback(null, response)
                        })
                    } else {
                        console.log('G')
                        response.statusCode = 404
                        response.body = JSON.stringify("resource not found")
                        callback(null, response)
                    }
                
                }
            })
        } else {
            console.log('H')
            const errorMessage = `'signInKey' parameter is malformed.`
            response.statusCode = 400
            response.body = JSON.stringify({ error: errorMessage })
            console.log(errorMessage, response)
            callback(null, response)
        }
    } else {
        console.log('I')
        const errorMessage = "'email' parameter is malformed."
        response.statusCode = 400
        response.body = JSON.stringify({ error: errorMessage })
        console.log(errorMessage, response)
        callback(null, response)
    }
}

const VerifyHash = (event, callback) => {
    const response = Object.assign({}, defaultResponse)
     // disable caching so this endpoint can always return a fresh result
    response.headers['Cache-Control'] = 'no-cache'
    console.log('B')
    // if authorization header not supplied
        // forbid access
    if (event.headers['Authorization']) {
        console.log('C')
        const authData = decrypt(JSON.parse(event.headers['Authorization']))
        const { email, signInKey, verificationStatus } = authData
        console.log('C1', authData)
        if (isValidEmailFormat(email)) {
            // if email exists in the admin table
                // proceed
            // else
                // reject
            const {
                ADMINS_TABLE
            } = process.env

            console.log('D')
            let params = {
                Key: {
                    'partitionKey': 'published',
                    email
                },
                TableName: ADMINS_TABLE
            }

            const dynamo = new AWS.DynamoDB.DocumentClient()
            dynamo.get(params, (err, data) => {
                if (err) {
                    console.log('E')
                    response.statusCode = err.statusCode
                    response.body = err.message
                    callback(null, response)
                } else {

                    const { Item } = data
                    if (Item) {

                        console.log('F', data)

                        // get signin key
                        // if not supplied then forbid access.
                        if (!signInKey) {
                            console.log('H')
                            const errorMessage = 'Unauthorized access.'
                            response.statusCode = 401
                            response.body = JSON.stringify({ error: errorMessage })
                            console.log(errorMessage, response)
                            callback(null, response)
                        }
                        // get submitted key
                        // if not supplied then forbid access.
                        const { submittedKey } = event.queryStringParameters
                        if (!submittedKey) {
                            console.log('I')
                            const errorMessage = '"submittedKey" parameter is malformed.'
                            response.statusCode = 401
                            response.body = JSON.stringify({ error: errorMessage })
                            console.log(errorMessage, response)
                            callback(null, response)
                        }
                        // does submitted key match signin key?
                        // if submitted key match signin key
                            // get subscriber
                        // else  forbid access.
                        if (signInKey === submittedKey) {
                            console.log('J', verificationStatus)
                            // if request is unverified
                                // mark as verified
                                // reset authorization hash to expire in 7 days (168 hours)
                            if (!verificationStatus) {
                                console.log('K')
                                const errorMessage = "verification status is missing."
                                response.statusCode = 400
                                response.body = JSON.stringify({ error: errorMessage })
                                console.log(errorMessage, response)
                                callback(null, response)
                            } else if(verificationStatus === 'unverified') {
                                console.log('L')
                                const newAuthData = Object.assign({}, authData, {
                                    verificationStatus: 'verified'
                                })
                                response.headers['Authorization'] = JSON.stringify(encrypt(newAuthData, 168))
                                console.log('L1', decrypt(JSON.parse(response.headers['Authorization'])))
                            }
                            response.body = JSON.stringify('success')
                            console.log(response)
                            callback(null, response)
                        } else {
                            console.log('M')
                            const errorMessage = 'Unauthorized access. "submittedKey" value is incorrect.'
                            response.statusCode = 401
                            response.body = JSON.stringify({ error: errorMessage })
                            console.log(errorMessage, response)
                            callback(null, response)
                        }
                        
                    } else {
                        console.log('N')
                        response.statusCode = 404
                        response.body = JSON.stringify("resource not found")
                        callback(null, response)
                    }
                
                }
            })

        } else {
            console.log('O')
            let errorMessage
            if(typeof authData === 'string') {
                response.statusCode = 401
                errorMessage = authData
            } else {
                response.statusCode = 400
                errorMessage = "'email' parameter is malformed."
            }
            response.body = JSON.stringify({ error: errorMessage })
            console.log(errorMessage, response)
            callback(null, response)
        }
    } else {
        console.log('P')
        const errorMessage = 'Unauthorized access.'
        response.statusCode = 401
        response.body = JSON.stringify({ error: errorMessage })
        console.log(errorMessage, response)
        callback(null, response)
    }
}

const GetS3UploadUrl = (event, callback) => {
     const response = Object.assign({}, defaultResponse)
      // disable caching so this endpoint can always return a fresh result
     response.headers['Cache-Control'] = 'no-cache'
     // verify hash then
        // append s3 url to response
    // else
        // forbid access
    // decrypt submitted key and pass it in to verify hash function to forgo submittedKey/signInKey step
    console.log('B')
    if(event.headers['Authorization']) {
        const { signInKey } = decrypt(JSON.parse(event.headers['Authorization']))
        event.queryStringParameters = Object.assign({}, event.queryStringParameters, {
            submittedKey: signInKey
        })
        VerifyHash(event, (error, response) => {
            console.log('C', response)
            if( response.statusCode === 200 ) {
                // append s3 url to response
                console.log('D')
                const {
                    EARTHBUCKET_MEDIA_BUCKET_NAME
                } = process.env
                AWS.config.update({ region: process.env.REGION || 'us-east-1' })
                const s3 = new AWS.S3()
                const signedUrls = []
                const urlAmount = Number(event.queryStringParameters.amount) || 1
                for (let i = 0; i < urlAmount; i++) {
                    const id = uuidv4()
                    const s3Params = {
                        Bucket: EARTHBUCKET_MEDIA_BUCKET_NAME,
                        Key:  `album/posts/images/${id}.jpg`,
                        ContentType: 'image/jpeg',
                        ACL: 'public-read',
                    }
                    const uploadURL = s3.getSignedUrl('putObject', s3Params)
                    signedUrls.push({
                        uploadURL,
                        "photoFilename": `${id}.jpg`
                    })
                }
                response.body = JSON.stringify(signedUrls)
                console.log('E', response)
                callback(null, response)
            } else {
                // else will return error message
                console.log('F')
                callback(null, response)
            }
        })
    } else {
        console.log('G')
        const errorMessage = 'Unauthorized access.'
        response.statusCode = 401
        response.body = JSON.stringify({ error: errorMessage })
        console.log(errorMessage, response)
        callback(null, response)
    }
}

const DeleteAlbumImages = (event, callback) => {
    const response = Object.assign({}, defaultResponse)
    console.log('B')
    // decrypt submitted key and pass it in to verify hash function to forgo submittedKey/signInKey step
    if(event.headers['Authorization']) {
        const { signInKey } = decrypt(JSON.parse(event.headers['Authorization']))
        event.queryStringParameters = Object.assign({}, event.queryStringParameters, {
            submittedKey: signInKey
        })
        VerifyHash(event, (error, response) => {
            console.log('C', response)
            if( response.statusCode === 200 ) {
                console.log('D')
                const {
                    EARTHBUCKET_MEDIA_BUCKET_NAME
                } = process.env
                AWS.config.update({ region: process.env.REGION || 'us-east-1' })
                const s3 = new AWS.S3()
                const { ids } = event.queryStringParameters
                if (ids) {
                    const Objects = ids.split(',').map( id => ({ Key: `album/posts/images/${id}.jpg` }))
                    s3.deleteObjects({
                        Bucket: EARTHBUCKET_MEDIA_BUCKET_NAME,
                        Delete: {
                            Objects
                        }
                    }, function(err, data) {
                        if (err) {
                            console.log('E', err)
                            response.statusCode = err.statusCode
                            response.body = err.message
                        } else {
                            response.statusCode = 204
                        }
                        callback(null, response)
                    })
                } else {
                    console.log('O')
                    const errorMessage = "'ids' parameter is required."
                    response.statusCode = 400
                    response.body = JSON.stringify({ error: errorMessage })
                    console.log(errorMessage, response)
                    callback(null, response)
                }
            } else {
                // else will return error message
                console.log('F')
                callback(null, response)
            }
        })
    } else {
        console.log('G')
        const errorMessage = 'Unauthorized access.'
        response.statusCode = 401
        response.body = JSON.stringify({ error: errorMessage })
        console.log(errorMessage, response)
        callback(null, response)
    }
}

const DeleteCloudFrontCache = (event, callback) => {
    const response = Object.assign({}, defaultResponse)
     // verify hash then
        // append s3 url to response
    // else
        // forbid access
    console.log('B')
    // decrypt submitted key and pass it in to verify hash function to forgo submittedKey/signInKey step
    if(event.headers['Authorization']) {
        const { signInKey } = decrypt(JSON.parse(event.headers['Authorization']))
        event.queryStringParameters = Object.assign({}, event.queryStringParameters, {
            submittedKey: signInKey
        })
        VerifyHash(event, (error, response) => {
            console.log('C', response)
            if( response.statusCode === 200 ) {
                console.log('D')
                const invalidationPaths = ['/*']
                invalidateCloudFrontCache(invalidationPaths)
                response.statusCode = 204
                callback(null, response)
            } else {
                // else will return error message
                console.log('E')
                callback(null, response)
            }
        })
    } else {
        console.log('G')
        const errorMessage = 'Unauthorized access.'
        response.statusCode = 401
        response.body = JSON.stringify({ error: errorMessage })
        console.log(errorMessage, response)
        callback(null, response)
    }
}

const invalidateCloudFrontCache = (paths, cb) => {
    const { AIRCDN_DISTRIBUTION_ID } = process.env
    var params = {
        DistributionId: AIRCDN_DISTRIBUTION_ID, /* required */
            InvalidationBatch: { /* required */
                CallerReference: moment().format(), /* required */
                Paths: { /* required */
                    Quantity: paths.length, /* required */
                    Items: paths
            }
        }
    }
    const cloudfront = new AWS.CloudFront({apiVersion: '2019-03-26'})
    cloudfront.createInvalidation(params, function (err, data) {
        if (err) {
            console.log(err, err.stack)  // an error occurred
        } else {
            console.log(data)            // successful response
            if(cb) {
                cb()
            }
        }
    })
}

// APIGateay base64 encodes event.body data, so decode it.
const decodeBase64 = (data, type = 'json') => {
    const buff = Buffer.from(data, 'base64')
    let result
    switch (type) {
        case 'json':
            result = JSON.parse(buff.toString('ascii'))
            break;
        case 'string':
            result = buff.toString('ascii')
            break;
    }
    return result
}

const getUnixTime = () => Math.round((new Date()).getTime() / 1000)

const isValidEmailFormat = email => {
  var re = /^(?:[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$/;
  return re.test(email);
}

const triggerGatsbyWebhook = () => {
    // call Gatsby Webhook to rebuild cloud application
    const {
        ENVIRONMENT,
        GATSBY_WEBHOOK_ID
    } = process.env
    let endpoint = 'https://webhook.gatsbyjs.com/hooks/data_source/'
    endpoint += ENVIRONMENT === 'prod' ? 'publish/' : ''
    endpoint += GATSBY_WEBHOOK_ID
    console.log('BA', endpoint)
    axios.post(endpoint)
}

module.exports = {
    GetFlightPermit,
    GetAlbumPosts,
    CreateAlbumPost,
    UpdateAlbumPost,
    DeleteAlbumPost,
    RequestGraphQL,
    SendAdminMagicLink,
    VerifyHash,
    GetS3UploadUrl,
    DeleteCloudFrontCache,
    DeleteAlbumImages
}