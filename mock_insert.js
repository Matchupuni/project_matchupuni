const { Pool } = require('pg');
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'matchupuni',
  password: 'yourpassword',
  port: 5432,
});

async function run() {
  try {
    const u1 = await pool.query(`SELECT id FROM users LIMIT 1;`);
    const u2 = await pool.query(`SELECT id FROM users OFFSET 1 LIMIT 1;`);
    if(u1.rows.length > 0 && u2.rows.length > 0) {
      const s = u1.rows[0].id;
      const r = u2.rows[0].id;
      console.log(`Sending from ${s} to ${r}`);
      await pool.query(`INSERT INTO messages (sender_id, receiver_id, message) VALUES ($1, $2, 'test msg')`, [s, r]);
      const res = await pool.query(`SELECT * FROM messages`);
      console.log(res.rows);
      
      const unread = await pool.query(`SELECT COUNT(*) as unread_count FROM messages WHERE receiver_id = $1 AND is_read = FALSE`, [r]);
      console.log('unread count query:', unread.rows);

      // Now query with joined users
      const getMsgs = await pool.query(
        `SELECT m.*, 
                s.full_name as sender_name, s.profile_img as sender_img,
                r.full_name as receiver_name, r.profile_img as receiver_img
         FROM messages m
         LEFT JOIN users s ON m.sender_id = s.id
         LEFT JOIN users r ON m.receiver_id = r.id
         WHERE (m.sender_id = $1 AND m.receiver_id = $2)
            OR (m.sender_id = $2 AND m.receiver_id = $1)`, [s, r]
      );
      console.log('joined messages:', getMsgs.rows);
    }
  } catch (err) {
    console.error(err);
  } finally {
    pool.end();
  }
}
run();
