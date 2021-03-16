talk to tj about

- [ ] github workflow error
- - https://github.com/averygoodidea/averygoodwebapp-infrastructure/actions/runs/645138474
- [ ] cloudfront to apigateway 500 error. What gives? I'm certain this error was carried over from the cloudformation architecture.
- - https://test-a.averygoodweb.app/api/1/album/posts/
- - https://d3dpold07lrmgw.cloudfront.net/api/1/album/posts
- - https://qlimaavatg.execute-api.us-east-1.amazonaws.com/test-a/api/1/album/posts/
- [x] how to pass in basic_auth.js tablename value
- - terraform/modules/lambda/basic_auth.tf
- - terraform/modules/lambda/lambda_handlers/basic_auth.js
- [x] change distributed repo to mono-repo
- [ ] update:
- - package_url = "https://raw.githubusercontent.com/averygoodidea/averygoodwebapp-waterapi/master/index.js"
- - to
- - package_url = "https://raw.githubusercontent.com/averygoodidea/averygoodwebapp/master/waterapi/index.js"
- [ ] complete waterapi initialization script
- - make `./scripts/init-environment.sh` invoke `./waterapi/scripts/init.sh`
- [ ] complete earthbucket initialization script
- - make `./scripts/init-environment.sh` invoke `./earthbucket/scripts/init.sh`
