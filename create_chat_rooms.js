require('dotenv').config();
const pool = require('./config/db');

async function createTables() {
  try {
    // 1. สร้างตาราง chat_rooms
    await pool.query(`
      CREATE TABLE IF NOT EXISTS chat_rooms (
          id SERIAL PRIMARY KEY,
          user1_id VARCHAR(255) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          user2_id VARCHAR(255) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          last_message_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);
    
    await pool.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS idx_chat_rooms_users ON chat_rooms(LEAST(user1_id, user2_id), GREATEST(user1_id, user2_id));
    `);
    console.log('✅ Created chat_rooms table');

    // 2. ตรวจสอบว่ามี column room_id ใน messages หรือยัง
    const colRes = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name='messages' AND column_name='room_id';
    `);
    
    if (colRes.rows.length === 0) {
      await pool.query(`
        ALTER TABLE messages 
        ADD COLUMN room_id INTEGER REFERENCES chat_rooms(id) ON DELETE CASCADE;
      `);
      console.log('✅ Added room_id to messages table');
    }

    // 3. ย้ายข้อมูลแชทเดิมให้ตรงหลืบ (Optional แต่ทำไว้ให้ครอบคลุม)
    await pool.query(`
      INSERT INTO chat_rooms (user1_id, user2_id)
      SELECT DISTINCT 
          LEAST(sender_id, receiver_id) AS user1_id, 
          GREATEST(sender_id, receiver_id) AS user2_id
      FROM messages
      ON CONFLICT (LEAST(user1_id, user2_id), GREATEST(user1_id, user2_id)) DO NOTHING;
    `);

    // อัปเดต room_id ในตาราง messages ให้เรียบร้อย
    await pool.query(`
      UPDATE messages m
      SET room_id = r.id
      FROM chat_rooms r
      WHERE 
         (m.sender_id = r.user1_id AND m.receiver_id = r.user2_id) OR
         (m.sender_id = r.user2_id AND m.receiver_id = r.user1_id)
      ;
    `);
    console.log('✅ Migrated existing messages to rooms');

    console.log('🎉 Done creating tables!');
  } catch (err) {
    console.error('❌ Error:', err);
  } finally {
    pool.end();
  }
}

createTables();
