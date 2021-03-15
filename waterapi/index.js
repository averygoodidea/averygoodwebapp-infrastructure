'use strict'
const WaterApi = require('./waterapi-v1/')
exports.handler = function(event, context, callback) {

    const { resource, httpMethod } = event
    
    console.log('A1', event)

    if (resource === '/api/1/album/posts') {

        switch (httpMethod) {

            case 'OPTIONS':

                WaterApi.GetFlightPermit(callback)

                break

            case 'GET':

                WaterApi.GetAlbumPosts(event, callback)

                break
        }
        
    } else if (resource === '/{proxy+}') {

        switch (httpMethod) {

            case 'OPTIONS':

                WaterApi.GetFlightPermit(callback)

                break

            default:

                WaterApi.RequestGraphQL(event, context)

                break
        }
        
    } else if (resource === '/api/1/admin/magic-link') {

        switch (httpMethod) {

            case 'OPTIONS':

                WaterApi.GetFlightPermit(callback)

                break

            case 'POST':

                WaterApi.SendAdminMagicLink(event, callback)

                break
        }
        
    } else if (resource === '/api/1/admin/hash') {

        switch (httpMethod) {

            case 'OPTIONS':

                WaterApi.GetFlightPermit(callback)

                break

            case 'GET':

                WaterApi.VerifyHash(event, callback)

                break
        }

    } else if (resource === '/api/1/admin/album/post') {

        switch (httpMethod) {

            case 'OPTIONS':

                WaterApi.GetFlightPermit(callback)

                break

            case 'POST':

                WaterApi.CreateAlbumPost(event, callback)

                break
        }

    } else if (resource === '/api/1/admin/album/posts/{id}') {

        switch (httpMethod) {

            case 'OPTIONS':

                WaterApi.GetFlightPermit(callback)

                break

            case 'PUT':

                WaterApi.UpdateAlbumPost(event, callback)

                break

            case 'DELETE':

                WaterApi.DeleteAlbumPost(event, callback)

                break
        }
        
    } else if (resource === '/api/1/admin/album/s3/urls') {

        switch (httpMethod) {

            case 'OPTIONS':

                WaterApi.GetFlightPermit(callback)

                break

            case 'GET':

                WaterApi.GetS3UploadUrl(event, callback)

                break
        }

    } else if (resource === '/api/1/admin/album/s3/images') {

        switch (httpMethod) {

            case 'OPTIONS':

                WaterApi.GetFlightPermit(callback)

                break

            case 'DELETE':

                WaterApi.DeleteAlbumImages(event, callback)

                break
        }

    } else if (resource === '/api/1/admin/cloudfront-cache') {

        switch (httpMethod) {

            case 'OPTIONS':

                WaterApi.GetFlightPermit(callback)

                break

            case 'DELETE':

                WaterApi.DeleteCloudFrontCache(event, callback)

                break
        }

    }
}