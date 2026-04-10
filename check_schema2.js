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
    const res = await pool.query(`SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'users';`);
    console.log(res.rows.find(c => c.column_name === 'id'));
  } catch (err) {
    console.error(err);
  } finally {
    pool.end();
  }
}
check();
