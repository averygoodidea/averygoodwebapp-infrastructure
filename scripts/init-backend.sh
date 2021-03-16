echo "\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "|a|V|e|r|y|G|o|o|d|W|e|b|A|p|p|"
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

if [ -z $profile ]; then
    echo "\nYou didn't provide a '--profile <awsProfile>' value. Exiting.\n"
    exit 1
fi

profile_status=$( (aws configure --profile ${profile} list ) 2>&1 )
if [[ $profile_status = *'could not be found'* ]]; then
    echo "AWS profile not found";
    exit 1
fi

# STEP 1
echo "\n-------"
echo "\nprogress [##                ] 11%"
echo "\nWhat is your domain name (example.com)?:"
echo "\nPlease leave out any www. prefix."
read domain_name

if [ -z $domain_name ]; then
    echo "\nYou didn't provide a domain name. Exiting."
    exit 1
fi

firerecord_zone=domain_name
namespace=${domain_name//./-}
terraform_backend_bucket="$namespace-terraform-backend"

# STEP 2
echo "\n-------"
echo "\nprogress [####              ] 22%"
echo "\nPaste in your 'aws_access_key_id' value:"
echo "\nThis value can be found by running the following command  'sudo nano ~/.aws/credentials' . You can find it under the aws profile you have been using for this installation guide."
aws_access_key_id=''
while IFS= read -r -s -n1 char; do
  [[ -z $char ]] && { printf '\n'; break; } # ENTER pressed; output \n and break.
  if [[ $char == $'\x7f' ]]; then # backspace was pressed
      # Remove last char from output variable.
      [[ -n $aws_access_key_id ]] && aws_access_key_id=${aws_access_key_id%?}
      # Erase '*' to the left.
      printf '\b \b' 
  else
    # Add typed char to output variable.
    aws_access_key_id+=$char
    # Print '*' in its stead.
    printf '*'
  fi
done

if [ -z $aws_access_key_id ]; then
    echo "\nYou didn't provide an 'aws_access_key_id' value. Exiting."
    exit 1
fi

# STEP 3
echo "\n-------"
echo "\nprogress [######            ] 33%"
echo "\nPaste in your 'aws_secret_access_key' value:"
echo "\nThis value can be found by running the following command  'sudo nano ~/.aws/credentials' . You can find it under the aws profile you have been using for this installation guide."
aws_secret_access_key=''
while IFS= read -r -s -n1 char; do
  [[ -z $char ]] && { printf '\n'; break; } # ENTER pressed; output \n and break.
  if [[ $char == $'\x7f' ]]; then # backspace was pressed
      # Remove last char from output variable.
      [[ -n $aws_secret_access_key ]] && aws_secret_access_key=${aws_secret_access_key%?}
      # Erase '*' to the left.
      printf '\b \b' 
  else
    # Add typed char to output variable.
    aws_secret_access_key+=$char
    # Print '*' in its stead.
    printf '*'
  fi
done

if [ -z $aws_secret_access_key ]; then
    echo "\nYou didn't provide an 'aws_secret_access_key' value. Exiting."
    exit 1
fi

# STEP 4
echo "\n-------"
echo "\nprogress [########          ] 44%"
echo "\nWhat AWS region is your account configured to?:"
echo "\nFor example, it could be: 'us-east-1'"
read region

if [ -z $region ]; then
    echo "\nYou didn't provide a 'region' value. Exiting."
    exit 1
fi

# STEP 5
echo "\n-------"
echo "\nprogress [##########        ] 55%"
echo "\nPaste in your 'gatsby_webhook_id' value:"
echo "\nthe string that connects the infrastructure to Gatsby Cloud. You can  copy and paste this value from gatsbyjs.com/dashboard/ > View Details  > Site Settings > Webhook. Under 'Preview Webhook', copy and  paste only the hash string at the end of the url."
gatsby_webhook_id=''
while IFS= read -r -s -n1 char; do
  [[ -z $char ]] && { printf '\n'; break; } # ENTER pressed; output \n and break.
  if [[ $char == $'\x7f' ]]; then # backspace was pressed
      # Remove last char from output variable.
      [[ -n $gatsby_webhook_id ]] && gatsby_webhook_id=${gatsby_webhook_id%?}
      # Erase '*' to the left.
      printf '\b \b' 
  else
    # Add typed char to output variable.
    gatsby_webhook_id+=$char
    # Print '*' in its stead.
    printf '*'
  fi
done

if [ -z $gatsby_webhook_id ]; then
    echo "\nYou didn't provide a 'gatsby_webhook_id' value. Exiting."
    exit 1
fi

# STEP 6
echo "\n-------"
echo "\nprogress [############      ] 66%"
echo "\nPlease provide an admin email address for your project:"
read sender_email_address

if [ -z $sender_email_address ]; then
    echo "\nYou didn't provide an admin email address. Exiting."
    exit 1
fi

# STEP 7
echo "\n-------"
echo "\nprogress [##############    ] 77%"
echo "\nWhat is your Tinyletter username?"
echo "\nPlease create a username at tinyletter.com, and then enter it here. This enables your web app to collect user emails out of the box."
read tinyletter_username

if [ -z $tinyletter_username ]; then
    echo "\nYou didn't provide Tinyletter username. Exiting."
    exit 1
fi

# STEP 8
echo "\n-------"
echo "\nprogress [################  ]88%"
echo "\nPaste in your 'valine_leancloud_app_id' value:"
echo "\nThis value enables the EarthBucket Comment Section and can be copied and pasted from https://console.leancloud.app/applist.html#/apps >  '<appTitle>'  > Settings > App keys. Copy the value from AppID."
valine_leancloud_app_id=''
while IFS= read -r -s -n1 char; do
  [[ -z $char ]] && { printf '\n'; break; } # ENTER pressed; output \n and break.
  if [[ $char == $'\x7f' ]]; then # backspace was pressed
      # Remove last char from output variable.
      [[ -n $valine_leancloud_app_id ]] && valine_leancloud_app_id=${gatsby_webhook_id%?}
      # Erase '*' to the left.
      printf '\b \b' 
  else
    # Add typed char to output variable.
    valine_leancloud_app_id+=$char
    # Print '*' in its stead.
    printf '*'
  fi
done

if [ -z $valine_leancloud_app_id ]; then
    echo "\nYou didn't provide 'valine_leancloud_app_id' value. Exiting."
    exit 1
fi

# STEP 9
echo "\n-------"
echo "\nprogress [################# ]99%"
echo "\nPaste in your 'valine_leancloud_app_key' value:"
echo "\nThis value enables the EarthBucket Comment Section and can be copied and pasted from https://console.leancloud.app/applist.html#/apps >  '<appTitle>'  > Settings > App keys. Copy the value from AppKey."
valine_leancloud_app_key=''
while IFS= read -r -s -n1 char; do
  [[ -z $char ]] && { printf '\n'; break; } # ENTER pressed; output \n and break.
  if [[ $char == $'\x7f' ]]; then # backspace was pressed
      # Remove last char from output variable.
      [[ -n $valine_leancloud_app_key ]] && valine_leancloud_app_key=${gatsby_webhook_id%?}
      # Erase '*' to the left.
      printf '\b \b' 
  else
    # Add typed char to output variable.
    valine_leancloud_app_key+=$char
    # Print '*' in its stead.
    printf '*'
  fi
done

if [ -z $valine_leancloud_app_key ]; then
    echo "\nYou didn't provide 'valine_leancloud_app_key' value. Exiting."
    exit 1
fi

echo "\nprogress [##################]100% 🚀"
# deploy terraform backend bucket
aws s3 mb s3://$terraform_backend_bucket --profile=$profile

# generate terraform backend.tf file
HYGEN_OVERWRITE=1 hygen terraform/backend.tf new        \
    --terraformBackendBucket=$terraform_backend_bucket  \
    --region=$region

# generate terraform variables.tf file
HYGEN_OVERWRITE=1 hygen terraform/variables.tf new      \
    --firerecordZone=$firerecord_zone                   \
    --region=$region                                    \
    --namespace=$namespace                              \
    --domainName=$domain_name                           \
    --senderEmailAddress=$sender_email_address

# generate terraform default terraform.tfvars \
HYGEN_OVERWRITE=1 hygen terraform/terraform.tfvars new  \
    --awsAccessKeyId=$aws_access_key_id                 \
    --awsSecretAccessKey=$aws_secret_access_key         \
    --domainName=$domain_name                           \
    --gatsbyWebhookId=$gatsby_webhook_id                \
    --tinyletterUsername=$tinyletter_username           \
    --valineLeanCloudAppId=$valine_leancloud_app_id     \
    --valineLeanCloudAppKey=$valine_leancloud_app_key

# initialize production environment
sh ./scripts/init-environment.sh                        \
    --domainName $domain_name                           \
    --environment "prod"