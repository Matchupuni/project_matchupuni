const { Pool } = require('pg');
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'matchupuni',
  password: 'yourpassword',
  port: 5432,
});

async function check() {
  try {
    const res = await pool.query(`SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'messages';`);
    console.log(res.rows);
  } catch (err) {
    console.error(err);
  } finally {
    pool.end();
  }
}
check();
