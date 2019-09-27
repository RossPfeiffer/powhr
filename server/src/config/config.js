module.exports={
	port: process.env.PORT || 8081,
	db:{
		database: process.env.DB_NAME || 'stats',
		user: process.env.DB_USER || 'stats',
		password: process.env.DB_PASS || 'admin',
		options:{
			host: process.env.HOST || 'localhost',	
			dialect: process.env.DIALECT || 'postgres',
			pool:{max:5,min:0,acquire:30000,idle:10000}
			//storage: './stats.sqlite'
		}
	}
}