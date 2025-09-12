// routes/education.js
const express = require('express');
const router = express.Router();
const db = require('../db'); // Your MySQL connection (mysql2)

router.post('/upsert', async (req, res) => {
  const { educations, firebase_uid } = req.body;

  try {
    // 1️⃣ Get user ID
    const [userRows] = await db.query('SELECT id FROM users WHERE firebase_uid = ?', [firebase_uid]);
    if (userRows.length === 0) return res.status(404).json({ error: 'User not found' });
    const userId = userRows[0].id;

    // 2️⃣ Get or create resume
    let [resumeRows] = await db.query('SELECT id FROM resumes WHERE user_id = ?', [userId]);
    let resumeId;

    if (resumeRows.length === 0) {
      // Create default resume
      const [insertResult] = await db.query(
        'INSERT INTO resumes (user_id, title) VALUES (?, ?)',
        [userId, 'My Resume']
      );
      resumeId = insertResult.insertId; // ✅ Correct insertId handling
    } else {
      resumeId = resumeRows[0].id;
    }

    // 3️⃣ Loop through educations and UPSERT
    for (let edu of educations) {
      const [existing] = await db.query(
        'SELECT id FROM education WHERE resume_id = ? AND institution = ? AND degree = ?',
        [resumeId, edu.institution_name, edu.degree]
      );

      if (existing.length > 0) {
        // Update existing education
        await db.query(
          `UPDATE education SET field_of_study = ?, start_date = ?, end_date = ? WHERE id = ?`,
          [edu.field_of_study, edu.start_year, edu.end_year, existing[0].id]
        );
      } else {
        // Insert new education
        await db.query(
          `INSERT INTO education (resume_id, institution, degree, field_of_study, start_date, end_date)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [resumeId, edu.institution_name, edu.degree, edu.field_of_study, edu.start_year, edu.end_year]
        );
      }
    }

    res.json({ message: 'Education saved/updated successfully!' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

module.exports = router;
