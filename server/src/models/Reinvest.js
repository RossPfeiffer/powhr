module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('Reinvest',{
		id: {
	        type: DataTypes.INTEGER,
	        autoIncrement: true,
	        primaryKey: true
	    },
		block: DataTypes.INTEGER,
		address: DataTypes.STRING,
		amount_reinvested: DataTypes.INTEGER,
		amount_dissolved: DataTypes.INTEGER,
		bonds_created: DataTypes.INTEGER,
		fee_paid: DataTypes.INTEGER
	})
}