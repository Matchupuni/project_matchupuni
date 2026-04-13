require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool(
  process.env.DATABASE_URL
    ? { connectionString: process.env.DATABASE_URL }
    : {
        user: process.env.DB_USER,
        host: process.env.DB_HOST,
        database: process.env.DB_DATABASE,
        password: process.env.DB_PASSWORD,
        port: process.env.DB_PORT,
      }
);

const migrate = async () => {
  try {
    console.log('Starting database migrations...');

    // 1. users
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(255) PRIMARY KEY,
        full_name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        profile_img TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✓ users table ensured');

    // 2. tags
    await pool.query(`
      CREATE TABLE IF NOT EXISTS tags (
        id SERIAL PRIMARY KEY,
        tag_name VARCHAR(255) UNIQUE NOT NULL
      )
    `);
    console.log('✓ tags table ensured');

    // 3. fields
    await pool.query(`
      CREATE TABLE IF NOT EXISTS fields (
        id SERIAL PRIMARY KEY,
        field_name VARCHAR(255) UNIQUE NOT NULL
      )
    `);
    console.log('✓ fields table ensured');

    // 4. posts
    await pool.query(`
      CREATE TABLE IF NOT EXISTS posts (
        id VARCHAR(255) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        details TEXT,
        due_date TIMESTAMP,
        register_link TEXT,
        image_path TEXT,
        post_type VARCHAR(50) DEFAULT 'activity',
        role_needed VARCHAR(255),
        teammates_needed INTEGER,
        required_skill TEXT,
        contact TEXT,
        author_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✓ posts table ensured');

    // 5. post_tags
    await pool.query(`
      CREATE TABLE IF NOT EXISTS post_tags (
        post_id VARCHAR(255) REFERENCES posts(id) ON DELETE CASCADE,
        tag_id INTEGER REFERENCES tags(id) ON DELETE CASCADE,
        PRIMARY KEY (post_id, tag_id)
      )
    `);
    console.log('✓ post_tags table ensured');

    // 6. post_fields
    await pool.query(`
      CREATE TABLE IF NOT EXISTS post_fields (
        post_id VARCHAR(255) REFERENCES posts(id) ON DELETE CASCADE,
        field_id INTEGER REFERENCES fields(id) ON DELETE CASCADE,
        PRIMARY KEY (post_id, field_id)
      )
    `);
    console.log('✓ post_fields table ensured');

    // 7. favorites
    await pool.query(`
      CREATE TABLE IF NOT EXISTS favorites (
        user_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
        post_id VARCHAR(255) REFERENCES posts(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, post_id)
      )
    `);
    console.log('✓ favorites table ensured');

    // 8. messages
    await pool.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        sender_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
        receiver_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
        message TEXT NOT NULL,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✓ messages table ensured');

    // 9. reports
    await pool.query(`
      CREATE TABLE IF NOT EXISTS reports (
        id VARCHAR(255) PRIMARY KEY,
        reporter_id VARCHAR(255) REFERENCES users(id) ON DELETE SET NULL,
        target_id VARCHAR(255) NOT NULL, -- Could be a user_id or post_id depending on report_type
        report_reason TEXT NOT NULL,
        report_type VARCHAR(50) DEFAULT 'user',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✓ reports table ensured');

    console.log('All migrations completed successfully!');
  } catch (error) {
    console.error('Error running migrations:', error);
    process.exit(1); // Exit with failure
  } finally {
    await pool.end();
  }
};

migrate();