const StatsController = require( './controllers/StatsController' )

module.exports = ( app ) => {
	app.post( '/pullInitialStats', StatsController.pullInitialStats )
	app.post( '/updateBackendStats', StatsController.updateBackendStats )
}