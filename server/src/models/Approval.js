module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('Approval',{
		id: {
	        type: DataTypes.INTEGER,
	        autoIncrement: true,
	        primaryKey: true
	    },
		block: DataTypes.INTEGER,
		address_to: DataTypes.STRING,
		address_from: DataTypes.STRING,
		amount_approved: DataTypes.INTEGER
	})
}