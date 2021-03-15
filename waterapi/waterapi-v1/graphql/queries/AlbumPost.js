'use strict'
const GraphQL = require('graphql')
const {
	GraphQLList,
	GraphQLString,
	GraphQLNonNull
} = GraphQL
console.log('E')
const AlbumPostType = require('../types/AlbumPost')
const AlbumPostResolver = require('../resolvers/AlbumPost')
module.exports = {
	index() {
		console.log('L')
		return {
			type: new GraphQLList(AlbumPostType),
			description: 'This will return all the album posts from DynamoDB.',
			resolve(parent, args, context, info) {
				return AlbumPostResolver.index()
			}
		}
	}
}