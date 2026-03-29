const { v4: uuidv4 } = require('uuid');
const { createId } = require('@paralleldrive/cuid2');

// Generate a version 4 (random) UUID
const generateUUID = () => {
  return uuidv4();
};

// Generate a collision-resistant cuid2 string
const generateCuid2 = () => {
  return createId();
};

module.exports = {
  generateUUID,
  generateCuid2,
};
