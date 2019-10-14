module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('SupplyTotal',{
		id: {
	        type: DataTypes.INTEGER,
	        autoIncrement: true,
	        primaryKey: true
	    },
		block: DataTypes.INTEGER,
		totalSupply: DataTypes.INTEGER
	})
}