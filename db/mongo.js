const mongoose = require('mongoose');
const Schema = mongoose.Schema;

mongoose.connect('mongodb://localhost/products');

const productsSchema = new Schema({
  id: { type: Number, unique: true },
  name: String,
  slogan: String,
  description: String,
  category: String,
  'default_price': Number,
  features: [
    { feature: String, value: String }
  ]
});

const skusSchema = new Schema({
  id: { type: Number, unique: true },
  skuData: {
    quantity: Number,
    size: String
  }
});

const stylesSchema = new Schema({
  id: { type: Number, unique: true },
  name: String,
  'original_price': Number,
  'sale_price': { type: Number, default: 0 },
  'default?': Boolean,
  photos: [
    { 'thumbnail_url': String, url: String }
  ],
  skus: [skusSchema]
});

const productStylesSchema = new Schema({
  'product_id': Number,
  results: [ [stylesSchema] ]
});

const Product = mongoose.model('Product', productsSchema);
const Style = mongoose.model('Style', productStylesSchema);

module.exports = {
  Product,
  Style
};