const WaterApiLambda = require('../../index')
const WaterApi = require('../../waterapi-v1/index')
const mockedEvent = {
	'resource': '',
	'httpMethod': ''
}
describe('WaterApi', () => {
	describe('GetFlightPermit', () => {
		it('should be called once by http method "OPTIONS", resource "/api/1/album/posts"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/api/1/album/posts',
				'httpMethod': 'OPTIONS'
			})
			jest.spyOn(WaterApi, 'GetFlightPermit').mockImplementationOnce(() => {})
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.GetFlightPermit).toHaveBeenCalledTimes(1)
			WaterApi.GetFlightPermit.mockRestore()
		})
		it('should contain Access-Control-Allow-* headers', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/api/1/album/posts',
				'httpMethod': 'OPTIONS'
			})

			const expected = {}
			expected['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE'
			expected['Access-Control-Allow-Headers'] = 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,x-requested-with'
			expected['Access-Control-Allow-Credentials'] = 'true'

			const callback = (err, result) => {
				expect(result.headers.hasOwnProperty('Access-Control-Allow-Methods')).toBe(true)
				expect(result.headers['Access-Control-Allow-Methods']).toEqual(expected['Access-Control-Allow-Methods'])
				expect(result.headers.hasOwnProperty('Access-Control-Allow-Headers')).toBe(true)
				expect(result.headers['Access-Control-Allow-Headers']).toEqual(expected['Access-Control-Allow-Headers'])
				//expect(result.headers.hasOwnProperty('Access-Control-Allow-Origin')).toBe(true)
				expect(result.headers.hasOwnProperty('Access-Control-Allow-Credentials')).toBe(true)
				expect(result.headers['Access-Control-Allow-Credentials']).toEqual(expected['Access-Control-Allow-Credentials'])
			}

			WaterApi.GetFlightPermit(callback)
		})
	})
	describe('GetAlbumPosts', () => {
		it('should be called once by http method "GET", resource "/api/1/album/posts"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/api/1/album/posts',
				'httpMethod': 'GET'
			})
			jest.spyOn(WaterApi, 'GetAlbumPosts').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.GetAlbumPosts).toHaveBeenCalledTimes(1)
			WaterApi.GetAlbumPosts.mockRestore()
		})
	})
	describe('CreateAlbumPost', () => {
		it('should be called once by http method "POST", resource "/api/1/admin/album/post"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/api/1/admin/album/post',
				'httpMethod': 'POST'
			})
			jest.spyOn(WaterApi, 'CreateAlbumPost').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.CreateAlbumPost).toHaveBeenCalledTimes(1)
			WaterApi.CreateAlbumPost.mockRestore()
		})
	})
	describe('UpdateAlbumPost', () => {
		it('should be called once by http method "PUT", resource "/api/1/admin/album/posts/{id}"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/api/1/admin/album/posts/{id}',
				'httpMethod': 'PUT'
			})
			jest.spyOn(WaterApi, 'UpdateAlbumPost').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.UpdateAlbumPost).toHaveBeenCalledTimes(1)
			WaterApi.UpdateAlbumPost.mockRestore()
		})
	})
	describe('DeleteAlbumPost', () => {
		it('should be called once by http method "PUT", resource "/api/1/admin/album/posts/{id}"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/api/1/admin/album/posts/{id}',
				'httpMethod': 'DELETE'
			})
			jest.spyOn(WaterApi, 'DeleteAlbumPost').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.DeleteAlbumPost).toHaveBeenCalledTimes(1)
			WaterApi.DeleteAlbumPost.mockRestore()
		})
	})
	describe('RequestGraphQL', () => {
		it('should be called once by http method "OPTIONS", resource "/{proxy+}"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/{proxy+}',
				'httpMethod': 'OPTIONS'
			})
			jest.spyOn(WaterApi, 'GetFlightPermit').mockImplementationOnce(() => {})
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.GetFlightPermit).toHaveBeenCalledTimes(1)
			WaterApi.GetFlightPermit.mockRestore()
		})
		it('should be called once by http method "GET", resource "/{proxy+}"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/{proxy+}',
				'httpMethod': 'GET'
			})
			jest.spyOn(WaterApi, 'RequestGraphQL').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.RequestGraphQL).toHaveBeenCalledTimes(1)
			WaterApi.RequestGraphQL.mockRestore()
		})
		it('should be called once by http method "POST", resource "/{proxy+}"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/{proxy+}',
				'httpMethod': 'POST'
			})
			jest.spyOn(WaterApi, 'RequestGraphQL').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.RequestGraphQL).toHaveBeenCalledTimes(1)
			WaterApi.RequestGraphQL.mockRestore()
		})
		it('should be called once by http method "PUT", resource "/{proxy+}"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/{proxy+}',
				'httpMethod': 'PUT'
			})
			jest.spyOn(WaterApi, 'RequestGraphQL').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.RequestGraphQL).toHaveBeenCalledTimes(1)
			WaterApi.RequestGraphQL.mockRestore()
		})
		it('should be called once by http method "DELETE", resource "/{proxy+}"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/{proxy+}',
				'httpMethod': 'DELETE'
			})
			jest.spyOn(WaterApi, 'RequestGraphQL').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.RequestGraphQL).toHaveBeenCalledTimes(1)
			WaterApi.RequestGraphQL.mockRestore()
		})
		it('should be called once by http method "POST", resource "/admin/magic-link"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/api/1/admin/magic-link',
				'httpMethod': 'POST'
			})
			jest.spyOn(WaterApi, 'SendAdminMagicLink').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.SendAdminMagicLink).toHaveBeenCalledTimes(1)
			WaterApi.SendAdminMagicLink.mockRestore()
		})
		it('should be called once by http method "GET", resource "/admin/hash"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/api/1/admin/hash',
				'httpMethod': 'GET'
			})
			jest.spyOn(WaterApi, 'VerifyHash').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.VerifyHash).toHaveBeenCalledTimes(1)
			WaterApi.VerifyHash.mockRestore()
		})
		it('should be called once by http method "GET", resource "/admin/album/s3/urls"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/api/1/admin/album/s3/urls',
				'httpMethod': 'GET'
			})
			jest.spyOn(WaterApi, 'GetS3UploadUrl').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.GetS3UploadUrl).toHaveBeenCalledTimes(1)
			WaterApi.GetS3UploadUrl.mockRestore()
		})
		it('should be called once by http method "DELETE", resource "/admin/album/s3/images"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/api/1/admin/album/s3/images',
				'httpMethod': 'DELETE'
			})
			jest.spyOn(WaterApi, 'DeleteAlbumImages').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.DeleteAlbumImages).toHaveBeenCalledTimes(1)
			WaterApi.DeleteAlbumImages.mockRestore()
		})
		it('should be called once by http method "DELETE", resource "/admin/cloudfront-cache"', () => {
			const event = Object.assign({}, mockedEvent, {
				'resource': '/api/1/admin/cloudfront-cache',
				'httpMethod': 'DELETE'
			})
			jest.spyOn(WaterApi, 'DeleteCloudFrontCache').mockImplementationOnce( () => {} )
			WaterApiLambda.handler(event, {}, () => {})
			expect(WaterApi.DeleteCloudFrontCache).toHaveBeenCalledTimes(1)
			WaterApi.DeleteCloudFrontCache.mockRestore()
		})
	})
})