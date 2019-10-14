module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('Stake',{
		id: {
	        type: DataTypes.INTEGER,
	        autoIncrement: true,
	        primaryKey: true
	    },
		block: DataTypes.INTEGER,
		address: DataTypes.STRING,
		amount_staked: DataTypes.INTEGER
	})
}