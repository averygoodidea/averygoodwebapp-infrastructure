while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

if [ -z $domainName ]; then
    echo "\nYou didn't provide an '--domainName <domainName>' value. Exiting.\n"
    exit 1
elif [ -z $environment ]; then
    echo "\nYou didn't provide an '--environment <environment>' value. Exiting.\n"
    exit 1
elif [ -z $profile ]; then
    echo "\nYou didn't provide a '--profile <awsProfile>' value. Exiting.\n"
    exit 1
fi

if [ "prod" != $environment ]; then
    domainName="${environment}.${domainName}"
fi

# hygen terraform environment.tfvars file
HYGEN_OVERWRITE=1 hygen terraform/environment new  \
    --domainName=$domainName                       \
    --environment=$environment

# initialize terraform environment
echo "initialize firerecord and aircdn, and partition for waterapi and earthbucket"
cd ./terraform
terraform workspace new $environment
terraform workspace select $environment
terraform apply -var-file=env/${environment}.tfvars

# initialize waterapi within terraform environment
echo "\ninitialize waterapi"
cd ../waterapi
npm install
cd ./test
npm install
cd ../

sh ./scripts/init.sh --environment $environment --profile $profile

# deploy earthbucket