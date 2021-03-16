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
elif [ -z $environment ]; then
    echo "\nYou didn't provide an '--environment <environment>' value. Exiting.\n"
    exit 1
fi
# deploy water-api files to aws
sh ./scripts/deploy.sh $environment $profile
# seed data into water-api
# > Please note, if the app doesn't have any album posts, then the specific test:
# >
# > "When a user visits the homepage" > "should get all album posts"
# >
# > will always fail because it is looking for items to return.
# >
# > The issue will resolve itself on all subsequent runs of this test.
# therefore, run this integration test twice
npm run test:integrations -- --environment=$environment
npm run test:integrations -- --environment=$environment
# publish api docs
cd ./docs
sh ./scripts/publish.sh $environment $profile
cd -