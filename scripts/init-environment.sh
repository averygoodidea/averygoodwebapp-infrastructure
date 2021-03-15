ENVIRONMENT=${1}
if [ -z $ENVIRONMENT ]; then
    echo "please provide an environment name as your first argument"
    exit 1
fi

# initialize backend.tf

# get firerecord_zone value and use for domain_name value
terraform_vars=$(cat ./terraform/terraform.tfvars)
str=$(sed '3!d' ./terraform/terraform.tfvars)
IFS='= ' # space is set as delimiter
read -ra ADDR <<< "$str"   # str is read into an array as tokens separated by IFS
for i in "${ADDR[@]}"; do   # access each element of array
    if [ "domain_name" != $i ]; then
        domain_name=$(echo $i | cut -d "\"" -f 2)
        if [ "prod" != $ENVIRONMENT ]; then
            domain_name="${ENVIRONMENT}.${domain_name}"
        fi
        echo "domain_name   = "\"${domain_name}\""\nenvironment   = \"${ENVIRONMENT}\"" > ./terraform/env/${ENVIRONMENT}.tfvars
    fi
done
# apply terraform to environment
cd ./terraform
terraform workspace new $ENVIRONMENT
terraform apply -var-file=env/${ENVIRONMENT}.tfvars
# deploy waterapi
# deploy earthbucket