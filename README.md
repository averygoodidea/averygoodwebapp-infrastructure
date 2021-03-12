# A Very Good Web App - Infrastructure

Prerequisites
- [An AWS Account with programmatic permission](https://aws.amazon.com/)
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
- [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

## Project Description

The Infrastructure for A Very Good Web App declares an AWS cloud evironment "stack" that hosts your web app (or website).

## Cloud Diagram

Here is a diagram of what the infrastructure looks like:

![A Very Good Web App Infrastructure Diagram](./averygoodwebapp-resource-map.svg)

More info can be found at https://averygoodweb.app.

## Infrastructure Deployment

aVeryGoodWebApp's infrastructure is created through [Terraform](https://terraform.io/).

Terraform is a very simple way to deploy backend resources necessary to house your web app. We use AWS as the cloud computing service of aAveryGoodWebApp. We have configured our Terraform script to work with AWS.

In order get your web app infrastructure installed, you must first create an AWS S3 Bucket to hold the terraform state.json file. You can create a bucket directly through [aws](https://s3.console.aws.amazon.com/s3/home), or through your terminal via the aws command line interface.

Once you have created your s3 bucket, navigate to the terraform folder:

`cd ./terraform`

update the following file:

`backend.tf`

and edit the `bucket` and `region` variables.

```
terraform {
  backend "s3" {
    bucket = "<bucketName>"
    key    = "state"
    region = "<region>"
  }
}
```

for example:

```
terraform {
  backend "s3" {
    bucket = "mydomainname-infrastructure-terraform"
    key    = "state"
    region = "us-east-1"
  }
}
```

To deploy this infrastructure for your app, open the following file:

`env/prod.tfvars`

and update the following variable value:

`domain_name = "<domainName>"`

for example

`domain_name = mydomainname.com`

then go to your terminal and run the following command:

`terraform apply` (when you are prompted, be sure to type, "yes")

Congratulations, your website/webapp's infrastructure is deployed!

Now you have a production environment. But wait, there's more!

what if you want to make changes to your infrastructure? Wouldn't that potentially break the site? Yes, it could. Which is why should create a terraform workspace for a lower environment, and then corresponding tfvars.

Once you do that, you can deploy a fresh infrastructure into a lower environment and develop in there while your production environment remains live. Once you are fine with your development environment, you can then deploy your changes into your production environment.

To create a lower environment, run the following command:

`terraform workspace new <environment>`

for example:

`terraform workspace new dev`

Then create a corresponding environment file here:

`env/<environment>.tfvars`

for example:

`env/dev.tfvars`

then run the following command:

`terraform apply -var-file=env/<environment>.tfvars`

for example:

`terraform apply -var-file=env/dev.tfvars`

## How To Update WaterApi ReST Endpoints

If you are creating a web app, you'll more than likely need to have customized [ReST](https://restfulapi.net/) endpoints. WaterApi uses [Swagger](https://swagger.io/blog/api-development/getting-started-with-swagger-i-what-is-swagger/) to declare it's endpoints.

To update the WaterApi ReST endpoints that map to your WaterApi functions, feel free to add, update or delete any endpoints found in the following files:

`modules/apigw/authenticated-api.yml`
`modules/apigw/unauthenticated-api.yml`

Note that the authenticated-api.yml file secures endpoints behind an auth token, while the unauthenticated-api.yml file exposes endpoints publically. Please architect your application wisely so that you don't expose sensitive data pubically.