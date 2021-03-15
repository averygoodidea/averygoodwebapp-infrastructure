# A Very Good Web App - WaterApi

![WaterAPI Icon](./docs/redoc/img/icon-water.svg)

Prerequisites
- [An AWS Account with programmatic permission](https://aws.amazon.com/)
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

## Project Description

This is a the back-end api for [averygoodweb.app](https://averygoodweb.app).

The **WaterApi** AWS Lambda Resource is declared in the [terraform](../terraform/modules/lambda/waterapi.tf) file.

This directory contains the JavaScript that gets deployed to the AWS Lambda Resource. Its subsequent methods are bound to the AWS API Gateway Resource through the following files:
- [authenticated endpoints](../terraform/modules/apigw/authenticated-api.yml)
- [unauthenticated endpoints](../terraform/modules/apigw/unauthenticated-api.yml)
- [endpoint-to-method map](./index.js)

## Local Development

#### Initialize Repo

1. Inside this repo, install the project node modules:

```
npm install
```

**Since this repo uses nvm v13 or higher. If there is any trouble running the repo, simply run the following command:**

`nvm use` and then re-run `npm install`

3. Initialize the WaterApi codebase

```
sh ./scripts/init.sh <environment> <awsProfile>
```

4. For all subsequent development, the best way to develop the api is to, iteratively

- - 1. write your code locally and then deploy to the remote environment,
- - 2. invoke the api using a tool like [PAW](https://paw.cloud/), and then
- - 3. utilize [AWS CloudWatch](https://console.aws.amazon.com/cloudwatch/home) to analyze your logs.

To deploy your updates, run the following command:

```
sh ./scripts/deploy.sh <environment> <awsProfile>
```

### Tests

Jest Tests can be run by the following command:
```
npm run test:units
npm run test:integrations -- --environment=<environment>
```

Swagger API Documentation instructions are located at [./docs/README.md](./docs/)
