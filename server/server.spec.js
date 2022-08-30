const request = require('supertest');
const app = require('./app.js');

// describe('Test the root path', () => {
//   it('It should respond to the GET method', async () => {
//     const res = await request(app).get('/products');

//     expect(res.statusCode).toBe(200);
//     expect(res.body).toEqual( {test: 'test'} );
//   });
// });

describe('Test overview service', () => {
  beforeAll((done) => {
    done();
  });

  afterAll((done) => {
    done();
  });

  it('It should respond to GET request with valid product id sent to /products/:product_id', async () => {
    const res = await request(app).get('/products/1');

    expect(res.statusCode).toBe(200);
    expect(res.body.id).toBe(1);
    expect(res.body.name).toBe('Camo Onesie');
    expect(typeof res.body.slogan).toBe('string');
    expect(typeof res.body.description).toBe('string');
    expect(res.body.category).toBe('Jackets');
    expect(res.body.default_price).toBe(140);
    expect(res.body.features.length).toBe(2);
  });

  it('It should respond to GET request with valid product id sent to /products/:product_id', async () => {
    const res = await request(app).get('/products/10');

    expect(res.statusCode).toBe(200);
    expect(res.body.id).toBe(10);
    expect(res.body.name).toBe('Infinity Stone');
    expect(typeof res.body.slogan).toBe('string');
    expect(typeof res.body.description).toBe('string');
    expect(res.body.category).toBe('Accessories');
    expect(res.body.default_price).toBe(5000000);
    expect(res.body.features.length).toBe(0);
  });

  it('It should respond to GET request with invalid product id sent to /products/:product_id', async () => {
    const res = await request(app).get('/products/1000012');

    expect(res.statusCode).toBe(404);
  });

  it('It should respond to GET request with valid product id sent to /products/:product_id/styles', async () => {
    const res = await request(app).get('/products/1/styles');

    expect(res.statusCode).toBe(200);
    expect(res.body.results.length).toBe(6);
    expect(res.body.results[0].style_id).toBe(1);
    expect(res.body.results[0].name).toBe('Forest Green & Black');
    expect(res.body.results[0].original_price).toBe(140);
    expect(res.body.results[0].sale_price).toBe(null);
    expect(res.body.results[0]['default?']).toBe(true);
    expect(res.body.results[0].photos.length).toBe(6);
    expect(res.body.results[0].skus['1'].quantity).toBe(8);
    expect(res.body.results[0].skus['1'].size).toBe('XS');
  });

  it('It should respond to GET request with valid product id sent to /products/:product_id/styles', async () => {
    const res = await request(app).get('/products/10/styles');

    expect(res.statusCode).toBe(200);
    expect(res.body.results.length).toBe(6);
    expect(res.body.results[0].style_id).toBe(47);
    expect(res.body.results[0].name).toBe('Reality');
    expect(res.body.results[0].original_price).toBe(500000000);
    expect(res.body.results[0].sale_price).toBe(null);
    expect(res.body.results[0]['default?']).toBe(true);
    expect(res.body.results[0].photos.length).toBe(1);
    expect(JSON.stringify(res.body.results[0].skus)).toBe(JSON.stringify({null: {quantity: null, size: null}}));
  });

  it('It should respond to GET request with invalid product id sent to /products/:product_id/styles', async () => {
    const res = await request(app).get('/products/1000012/styles');

    expect(res.statusCode).toBe(200);
    expect(res.body.results.length).toBe(0);
  });

  it('It should respond to GET request with valid product id sent to /products/:product_id/related', async () => {
    const res = await request(app).get('/products/1/related');
    console.log(res.body);

    expect(res.statusCode).toBe(200);
    expect(res.body.length).toBe(4);
    expect(res.body[0]).toBe(2);
  });

  it('It should respond to GET request with valid product id sent to /products/:product_id/related', async () => {
    const res = await request(app).get('/products/10/related');

    expect(res.statusCode).toBe(200);
    expect(res.body.length).toBe(0);
  });

  it('It should respond to GET request with invalid product id sent to /products/:product_id/related', async () => {
    const res = await request(app).get('/products/1000012/related');

    expect(res.statusCode).toBe(200);
    expect(res.body.length).toBe(0);
  });
});