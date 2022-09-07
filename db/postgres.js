const { Client, Pool } = require('pg');
const { user, host, database, password, port } = require('../dbConfig');

const client = new Client({
  user,
  host,
  database,
  password,
  port,
});

client.connect();

const pool = new Pool({
  user,
  host,
  database,
  password,
  port,
});

// pool.connect();

module.exports = pool;