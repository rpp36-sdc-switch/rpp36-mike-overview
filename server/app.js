const express = require('express');
const models = require('./../db/models.js');
const morgan = require('morgan');

const app = express();

app.use(morgan('tiny'));
app.use(express.json());
app.use(express.urlencoded( {extended: true} ));

// Get Product Info
app.get('/products/:product_id', (req, res) => {
  models.productInfo.get(req.params.product_id, (err, result) => {
    if (err) {
      res.status(err.status).send(err.message);
    } else {
      res.status(200).send(result);
    }
  });
});

// Get Product Styles
app.get('/products/:product_id/styles', (req, res) => {
  models.productStyles.get(req.params.product_id, (err, result) => {
    if (err) {
      res.status(err.status).send(err.message);
    } else {
      res.status(200).send(result);
    }
  });
});

// Get Related Products
app.get('/products/:product_id/related', (req, res) => {
  models.relatedProducts.get(req.params.product_id, (err, result) => {
    if (err) {
      res.status(err.status).send(err.message);
    } else {
      res.status(200).send(result);
    }
  });
});

// Initial Test Route
// app.get('/products', (req, res) => {
//   res.status(200).send({ test: 'test' });
// });

module.exports = app;