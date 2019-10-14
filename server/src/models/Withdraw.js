module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('Withdraw',{
		id: {
	        type: DataTypes.INTEGER,
	        autoIncrement: true,
	        primaryKey: true
	    },
		block: DataTypes.INTEGER,
		address: DataTypes.STRING,
		eth_earned: DataTypes.INTEGER,
		resolves_dissolved: DataTypes.INTEGER
	})
}