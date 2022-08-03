const request = require("supertest");
const app = require('./app.js');

describe('Test the root path', () => {
  test('It should respond to the GET method', async () => {
    const res = await request(app).get("/products");

    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual( {test: 'test'} );
  });
});