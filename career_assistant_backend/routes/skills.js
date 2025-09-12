const express = require('express');
const router = express.Router();
const db = require('../db');

router.post('/upsert', async (req, res) => {
  const { firebase_uid, skills } = req.body; // array of {skill_name, proficiency_level}

  try {
    // 1️⃣ Get user ID
    const [userRows] = await db.query('SELECT id FROM users WHERE firebase_uid=?', [firebase_uid]);
    if (userRows.length === 0) return res.status(404).json({ error: 'User not found' });
    const userId = userRows[0].id;

    // 2️⃣ Get or create resume
    let [resumeRows] = await db.query('SELECT id FROM resumes WHERE user_id = ?', [userId]);
    let resumeId;
    if (resumeRows.length === 0) {
      const [insertResult] = await db.query(
        'INSERT INTO resumes (user_id, title) VALUES (?, ?)',
        [userId, 'My Resume']
      );
      resumeId = insertResult.insertId;
    } else {
      resumeId = resumeRows[0].id;
    }

    // 3️⃣ Insert/Update skills
    for (const skill of skills) {
      // Optional: check if skill already exists
      const [existing] = await db.query(
        'SELECT id FROM skills WHERE resume_id = ? AND skill_name = ?',
        [resumeId, skill.skill_name]
      );

      if (existing.length > 0) {
        await db.query(
          'UPDATE skills SET proficiency_level = ? WHERE id = ?',
          [skill.proficiency_level, existing[0].id]
        );
      } else {
        await db.query(
          'INSERT INTO skills (resume_id, skill_name, proficiency_level) VALUES (?, ?, ?)',
          [resumeId, skill.skill_name, skill.proficiency_level]
        );
      }
    }

    res.json({ message: 'Skills saved/updated successfully!' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

module.exports = router;
