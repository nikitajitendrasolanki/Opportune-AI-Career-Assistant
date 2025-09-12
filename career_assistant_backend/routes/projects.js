const express = require('express');
const router = express.Router();
const db = require('../db');

router.post('/upsert', async (req, res) => {
  const { firebase_uid, projects } = req.body; // array of projects

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

    // 3️⃣ Insert or update projects
    for (const proj of projects) {
      const [existing] = await db.query(
        'SELECT id FROM projects WHERE resume_id = ? AND project_title = ?',
        [resumeId, proj.project_title]
      );

      if (existing.length > 0) {
        await db.query(
          `UPDATE projects
           SET project_description = ?, technologies_used = ?, project_link = ?
           WHERE id = ?`,
          [proj.project_description, proj.technologies_used, proj.project_link, existing[0].id]
        );
      } else {
        await db.query(
          `INSERT INTO projects (resume_id, project_title, project_description, technologies_used, project_link)
           VALUES (?, ?, ?, ?, ?)`,
          [resumeId, proj.project_title, proj.project_description, proj.technologies_used, proj.project_link]
        );
      }
    }

    res.json({ message: 'Projects saved/updated successfully!' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

module.exports = router;
