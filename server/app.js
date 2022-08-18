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
      res.status(500).send(err.message);
    } else {
      res.status(200).send( { results: result });
    }
  });
});

app.post('/products/:product_id', (req, res) => {
  models.productInfo.post(req.params.product_id, (err, result) => {
    if (err) {
      res.status(500).send(err.message);
    } else {
      res.status(201).send( { results: result });
    }
  });
});

// Get Product Styles
app.get('/products/:product_id/styles', (req, res) => {
  models.productStyles.get(req.params.product_id, (err, result) => {
    if (err) {
      res.status(500).send(err.message);
    } else {
      res.status(200).send( { results: result });
    }
  });
});

app.post('/products/:product_id/styles', (req, res) => {
  models.productStyles.post(req.params.product_id, (err, result) => {
    if (err) {
      res.status(500).send(err.message);
    } else {
      res.status(201).send( { results: result });
    }
  });
});


// Initial Test Route
// app.get('/products', (req, res) => {
//   res.status(200).send({ test: 'test' });
// });

module.exports = app;