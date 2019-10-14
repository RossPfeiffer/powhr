module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('SellPrice',{
		id: {
	        type: DataTypes.INTEGER,
	        autoIncrement: true,
	        primaryKey: true
	    },
		price: DataTypes.INTEGER,
		block: DataTypes.INTEGER
	})
}