const express = require('express');
// const morgan = require('morgan');

const app = express();

// app.use(morgan('tiny'));
app.use(express.json());
app.use(express.urlencoded( {extended: true} ));

app.get('/products', (req, res) => {
  res.status(200).send({ test: 'test' });
});

module.exports = app;