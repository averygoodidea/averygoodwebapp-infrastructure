---
to: ./.env
---
# an admin email for your project
AWS_WATERAPI_EMAIL=<%= awsWaterApiEmail %>

# this project's domain name
DOMAIN_NAME=<%= domainName %>

# a work-around to enable a stack to be deployed while a previous Lambda@Edge function deletes.
# Generate string from random.org, and only update it if CloudFormation throws an error that
# it cannot delete EarthBucketBasicAuthLambdaEdge.
# This was auto generated when you created your settings file.
CACHE_HASH=<%= cacheHash %>

# the string that connects the infrastructure to Gatsby Cloud. You can copy and paste this value from
# gatsbyjs.com/dashboard/ > View Details > Site Settings > Webhook. Under "Preview Webhook", copy and paste
# only the hash string at the end of the url.
GATSBY_WEBHOOK_ID=<%= gatsbyWebhookId %>
