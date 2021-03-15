'use strict'
const GraphQL = require('graphql')
const {
	GraphQLObjectType,
	GraphQLSchema
} = GraphQL
console.log('C')
const AlbumPostQuery = require('./queries/AlbumPost')
const RootQuery = new GraphQLObjectType({
	name: 'RootQueryType',
	description: 'This is the default root query provided by our application.',
	fields: {
		albumPosts: AlbumPostQuery.index()
	}
})
module.exports = new GraphQLSchema({
	query: RootQuery
})