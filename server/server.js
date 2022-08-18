// require('dotenv').config();
const app = require('./app.js');
const PORT = 5280;

app.listen(PORT, () => {
  console.log(`listening on port ${PORT}`);
});