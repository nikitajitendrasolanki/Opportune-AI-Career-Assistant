const express = require('express');
const router = express.Router();
const db = require('../db');

router.post('/upsert', async (req, res) => {
  const { firebase_uid, experiences } = req.body;

  if (!firebase_uid || !experiences) {
    return res.status(400).json({ error: "firebase_uid and experiences required" });
  }

  try {
    // 🔍 user find karo
    const [userRows] = await db.query('SELECT id FROM users WHERE firebase_uid=?', [firebase_uid]);
    if (userRows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userId = userRows[0].id;

    for (const exp of experiences) {
      const startDate = exp.start_date || null;
      const endDate = exp.end_date || null;
      const expId = exp.id ? parseInt(exp.id, 10) : null;

      if (expId) {
        // 🔄 Update existing record
        await db.query(
          `UPDATE experience
           SET job_title=?, company_name=?, location=?, start_date=?, end_date=?, currently_working=?, description=?
           WHERE id=? AND user_id=?`,
          [
            exp.job_title,
            exp.company_name,
            exp.location || null,
            startDate,
            endDate,
            exp.currently_working ? 1 : 0,
            exp.description,
            expId,
            userId,
          ]
        );
      } else {
        // ➕ Insert new record
        await db.query(
          `INSERT INTO experience
           (user_id, job_title, company_name, location, start_date, end_date, currently_working, description)
           VALUES (?,?,?,?,?,?,?,?)`,
          [
            userId,
            exp.job_title,
            exp.company_name,
            exp.location || null,
            startDate,
            endDate,
            exp.currently_working ? 1 : 0,
            exp.description,
          ]
        );
      }
    }

    res.json({ message: 'Experiences saved/updated successfully ✅' });
  } catch (err) {
    console.error("SQL Error:", err.sqlMessage || err.message);
    res.status(500).json({ error: err.sqlMessage || 'Database error' });
  }
});

// 👇👇👇  YE sabse zaroori hai
module.exports = router;
