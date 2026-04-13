const pool = require('../config/db');
const { generateCuid2 } = require('../utils/idGenerator');

const submitReport = async (req, res) => {
  try {
    const { reporter_id, target_id, report_reason, report_type } = req.body;
    
    if (!reporter_id || !target_id || !report_reason) {
      return res.status(400).json({ error: 'Missing required report fields' });
    }

    const id = generateCuid2();
    const type = report_type || 'post'; // Default to post for now

    const query = `
      INSERT INTO reports (id, reporter_id, target_id, report_reason, report_type)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `;
    const result = await pool.query(query, [id, reporter_id, target_id, report_reason, type]);
    
    res.status(201).json({ message: 'Report submitted successfully', report: result.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message || 'Internal Server Error', stack: error.stack });
  }
};

module.exports = {
  submitReport
};
