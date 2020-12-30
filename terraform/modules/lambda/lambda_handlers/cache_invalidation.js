const AWS = require('aws-sdk')
const { AIRCDN_DISTRIBUTION_ID, QUEUE_URL, REGION } = process.env
AWS.config.update({ region: REGION })

// Create an SQS service object
const sqs = new AWS.SQS({apiVersion: '2012-11-05'})

exports.handler = function (event, context) {
  // https://gist.github.com/gordonbrander/2230317#gistcomment-3244708
  const createID = () => {
      return Array(16)
        .fill(0)
        .map(() => String.fromCharCode(Math.floor(Math.random() * 26) + 97))
        .join('') +
        Date.now().toString(24)
  }
  const cloudfront = new AWS.CloudFront({apiVersion: '2019-03-26'})
  const invalidateCloudFrontCache = paths => {
    var params = {
        DistributionId: AIRCDN_DISTRIBUTION_ID, /* required */
            InvalidationBatch: { /* required */
                CallerReference: createID(), /* required */
                Paths: { /* required */
                    Quantity: paths.length, /* required */
                    Items: paths
            }
        }
    }
    cloudfront.createInvalidation(params, function (err, data) {
        if (err) {
            console.log(err, err.stack)  // an error occurred
        } else {
            console.log(data)            // successful response
        }
    })
  }
  var params = {
    QueueUrl: QUEUE_URL, /* required */
    AttributeNames: [
      'All',
    ]
  }
  sqs.getQueueAttributes(params, function(err, data) {
    if (err) {
      //console.log('C', err, err.stack)
      return false
    } else {
      const {
        ApproximateNumberOfMessages,
        ApproximateNumberOfMessagesNotVisible,
        ApproximateNumberOfMessagesDelayed
      } = data.Attributes

      //console.log(data)

      // If SQS is empty
        // invalidate Cloudfront

      params = {
        DistributionId: AIRCDN_DISTRIBUTION_ID,
        MaxItems: '5'
      }
      cloudfront.listInvalidations(params, function(err, data) {
        if (err) {
          console.log(err, err.stack)
        }
        else {
          // loop through items
          // if no item status is in progress
            // invalidate
          // else if queue appears empty
            // invalidate
          const invalidationPaths = ['/*']
          const statuses = []
          data.Items.forEach( ({ Status }) => statuses.push(Status))
          if(!statuses.includes('InProgress')) {
            //console.log('E1')
            invalidateCloudFrontCache(invalidationPaths)
          } else {
            if (Number(ApproximateNumberOfMessages) <= 1 && Number(ApproximateNumberOfMessagesNotVisible) <= 20  && Number(ApproximateNumberOfMessagesDelayed) <= 1 ) {
              const invalidationPaths = ['/*']
              invalidateCloudFrontCache(invalidationPaths)
            }
          }
        }
      })
    }
  })
}