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
    const res = await pool.query(`SELECT column_default FROM information_schema.columns WHERE table_name = 'messages' AND column_name = 'is_read';`);
    console.log(res.rows[0]);
  } catch (err) {
    console.error(err);
  } finally {
    pool.end();
  }
}
check();
