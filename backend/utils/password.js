const argon2 = require('argon2');

/**
 * Hash a plain text password using Argon2id
 * @param {string} password - The plain text password
 * @returns {Promise<string>} The hashed password
 */
const hashPassword = async (password) => {
  try {
    const hash = await argon2.hash(password, {
      type: argon2.argon2id // Explicitly use argon2id as requested
    });
    return hash;
  } catch (err) {
    throw new Error('Error hashing password');
  }
};

/**
 * Verify a plain text password against an Argon2id hash
 * @param {string} hash - The hashed password stored in the database
 * @param {string} password - The plain text password provided by the user
 * @returns {Promise<boolean>} True if the password matches, false otherwise
 */
const verifyPassword = async (hash, password) => {
  try {
    return await argon2.verify(hash, password);
  } catch (err) {
    throw new Error('Error verifying password');
  }
};

module.exports = {
  hashPassword,
  verifyPassword
};
