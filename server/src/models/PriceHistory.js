module.exports=(sequelize, DataTypes)=>{
	return sequelize.define('PriceHistory',{
		price: DataTypes.INTEGER
	})
}