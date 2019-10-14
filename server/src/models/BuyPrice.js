module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('BuyPrice',{
		id: {
	        type: DataTypes.INTEGER,
	        autoIncrement: true,
	        primaryKey: true
	    },
		price: DataTypes.INTEGER,
		block: DataTypes.INTEGER
	})
}