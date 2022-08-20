const { Client } = require('pg');
const { user, host, database, password, port } = require('../dbConfig');

const db = new Client({
  user,
  host,
  database,
  password,
  port,
});

db.connect();

module.exports = db;