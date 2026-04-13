const pool = require('../config/db');
const { generateCuid2 } = require('../utils/idGenerator');

const submitReport = async (req, res) => {
  try {
    // req.user is set by authMiddleware
    const reporter_id = req.user.id; 
    const { target_id, report_reason, report_type } = req.body;

    if (!target_id || !report_reason) {
      return res.status(400).json({ error: 'target_id and report_reason are required' });
    }

    const id = generateCuid2();

    const result = await pool.query(
      `INSERT INTO reports (id, reporter_id, target_id, report_reason, report_type) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING *`,
      [id, reporter_id, target_id, report_reason, report_type || 'user']
    );

    res.status(201).json({ message: 'Report submitted successfully', report: result.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message || 'Internal Server Error', stack: error.stack });
  }
};

module.exports = {
  submitReport
};
