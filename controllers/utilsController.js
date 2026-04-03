const { generateUUID, generateCuid2 } = require('../utils/idGenerator');

const generateIds = (req, res) => {
  res.json({
    uuid: generateUUID(),
    cuid2: generateCuid2()
  });
};

module.exports = {
  generateIds
};
