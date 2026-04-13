const { createId } = require('@paralleldrive/cuid2');

// Generate a collision-resistant cuid2 string
const generateCuid2 = () => {
  return createId();
};

module.exports = {
  generateCuid2,
};
