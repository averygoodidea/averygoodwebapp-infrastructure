ENVIRONMENT=$1
AWS_PROFILE=$2
# deploy water-api files to aws
sh ./scripts/deploy.sh $ENVIRONMENT $AWS_PROFILE
# seed data into water-api
# > Please note, if the app doesn't have any album posts, then the specific test:
# >
# > "When a user visits the homepage" > "should get all album posts"
# >
# > will always fail because it is looking for items to return.
# >
# > The issue will resolve itself on all subsequent runs of this test.
# therefore, run this integration test twice
npm run test:integrations -- --environment=$ENVIRONMENT
npm run test:integrations -- --environment=$ENVIRONMENT
# publish api docs
cd ./docs
sh ./scripts/publish.sh $ENVIRONMENT $AWS_PROFILE
cd -