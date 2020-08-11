// Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Amazon Software License
// http://aws.amazon.com/asl/

module.exports = {
    prompt: async ({ prompter }) => {
        const sequentiallyPrompt = async prompts => {
            let promptResults = {};
            // sequentially prompt for settings
            for (let i = 0; i < prompts.length; ++i) {
                promptResults = { ...promptResults, ...(await prompter.prompt(prompts[i])) };
            }
            return promptResults;
        };

        const topLevelGeneralSettings = [
            {
                type: 'input',
                name: 'awsWaterApiEmail',
                message: `AWS_WATERAPI_EMAIL:
        Water API Email
        ------------------------------------------    
        an admin email for your project
        
        Type the admin email - `,
            },
            {
                type: 'input',
                name: 'domainName',
                message: `DOMAIN_NAME:
        Domain Name
        ------------------------------------------    
        this project's domain name
        
        Type the domain name - `
            },
            {
                type: 'input',
                name: 'gatsbyWebhookId',
                message: `GATSBY_WEBHOOK_ID:
        Gatsby Webhook ID
        ------------------------------------------ 
        the string that connects the infrastructure to Gatsby Cloud. You can copy and paste this value from 
        gatsbyjs.com/dashboard/ > View Details > Site Settings > Webhook. 
        Under "Preview Webhook", copy and paste only the hash string at the end of the url.
        
        Type Gatsby Webhook ID - `
            },

        ];
        let allPromptResults = await sequentiallyPrompt(topLevelGeneralSettings);


        const getRandomString = () =>{
            return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
        }

        allPromptResults.cacheHash = getRandomString()

        return allPromptResults;
    },
};
