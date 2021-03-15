'use strict';
const GraphQL = require('graphql')
const {
	GraphQLObjectType,
	GraphQLID,
	GraphQLString,
	GraphQLInt,
	GraphQLList
} = GraphQL
console.log('F')
const AlbumPostType = new GraphQLObjectType({
	name: 'AlbumPost',
	description: 'AlbumPost Type, For all album post records in DynamoDB',
	fields: () => ({
		id: {
			type: GraphQLID,
			description: 'ID of the post'
		},
		createdAt: {
			type: GraphQLInt,
			description: 'when this post was created'
		},
		slugId: {
			type: GraphQLString,
			description: 'url-safe slug id of post'
		},
		title: {
			type: GraphQLString,
			description: 'name of the post'
		},
		summary: {
			type: GraphQLString,
			description: 'summary of the post'
		},
		images: {
			type: new GraphQLList(GraphQLString),
			description: 'images of the post'
		},
		categories: {
			type: new GraphQLList(GraphQLString),
			description: 'categories of the post'
		},
		price: {
			type: GraphQLInt,
			description: 'price of the post'
		},
		moreInfoUrl: {
			type: GraphQLString,
			description: 'external url to learn more about the post'
		}
	})
})
module.exports = AlbumPostType