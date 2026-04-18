require('dotenv').config();
const { Pool } = require('pg');

const hasDatabaseUrl = !!process.env.DATABASE_URL;
const hasLocalDbParams = !!(process.env.DB_HOST && process.env.DB_USER && process.env.DB_DATABASE);

if (!hasDatabaseUrl && !hasLocalDbParams) {
  console.warn('⚠️ WARNING: Database environment variables are missing (this is normal during Docker build phase).');
}

const pool = new Pool(
  process.env.DATABASE_URL
    ? {
        connectionString: process.env.DATABASE_URL,
        // Uncomment the lines below if Dokku PG forces SSL (usually not needed for internal Dokku networks)
        // ssl: {
        //   rejectUnauthorized: false,
        // },
      }
    : {
        user: process.env.DB_USER,
        host: process.env.DB_HOST,
        database: process.env.DB_DATABASE,
        password: process.env.DB_PASSWORD,
        port: process.env.DB_PORT,
      }
);

pool.on('error', (err, client) => {
  console.error('🚨 Unexpected error on idle client', err);
  process.exit(-1);
});

module.exports = pool;
