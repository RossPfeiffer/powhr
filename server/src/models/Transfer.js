module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('Transfer',{
		id: {
	        type: DataTypes.INTEGER,
	        autoIncrement: true,
	        primaryKey: true
	    },
		block: DataTypes.INTEGER,
		address_to: DataTypes.STRING,
		address_from: DataTypes.STRING,
		amount_transferred: DataTypes.INTEGER,
		data: DataTypes.STRING
	})
}