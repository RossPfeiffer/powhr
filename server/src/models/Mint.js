module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('Mint',{
		id: {
	        type: DataTypes.INTEGER,
	        autoIncrement: true,
	        primaryKey: true
	    },
		block: DataTypes.INTEGER,
		address: DataTypes.STRING,
		amount_minted: DataTypes.INTEGER
	})
}