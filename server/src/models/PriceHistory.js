module.exports=(sequelize, DataTypes)=>{
	sequelize.define('PriceHistory',{
		price: DataTypes.INTEGER
	})
}