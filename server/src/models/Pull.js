module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('Pull',{
		id: {
	        type: DataTypes.INTEGER,
	        autoIncrement: true,
	        primaryKey: true
	    },
		block: DataTypes.INTEGER,
		address: DataTypes.STRING,
		amount_pulled: DataTypes.INTEGER,
		forfeited_eth: DataTypes.INTEGER
	})
}