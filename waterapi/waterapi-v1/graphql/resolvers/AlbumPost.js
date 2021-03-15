'use strict'
const WaterApi = require('../../')
console.log('G')
const AlbumPostsController = {
	index: () => {
	    return (new Promise( (resolve, reject) => {
	    	WaterApi.GetAlbumPosts({}, (error, response) => {
	    		resolve(JSON.parse(response.body))
	    	})
	    }))
	    .catch( error => {
	    	console.log('K', error)
	    	return {
	    		'error': error
	    	}
	    })
	}
}
module.exports = AlbumPostsController