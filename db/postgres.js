// import environment variables
require('dotenv').config();

const { Client } = require('pg');

const db = new Client({
  host: PGHOST,
  user: PGUSER,
  port: 3000,
  password: PGPASSWORD,
  database: 'overview',
});

db.connect();