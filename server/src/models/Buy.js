module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('Buy',{
		id: {
	        type: DataTypes.INTEGER,
	        autoIncrement: true,
	        primaryKey: true
	    },
		block: DataTypes.INTEGER,
		address: DataTypes.STRING,
		bonds_created: DataTypes.INTEGER,
		fee_paid: DataTypes.INTEGER
	})
}