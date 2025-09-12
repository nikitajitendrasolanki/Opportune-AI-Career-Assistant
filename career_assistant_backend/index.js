const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = 5000;

app.use(cors());
app.use(bodyParser.json());

// Routes
app.use('/users', require('./routes/users'));
app.use('/education', require('./routes/education'));
app.use('/experience', require('./routes/experience'));
app.use('/skills', require('./routes/skills'));
app.use('/projects', require('./routes/projects'));
app.use('/certifications', require('./routes/certifications'));
app.use('/languages', require('./routes/languages'));
app.use('/social_links', require('./routes/social_links'));
app.use('/resume', require('./routes/resume'));  // ✅ resume route

app.listen(PORT, '0.0.0.0', () =>
  console.log(`Server running on http://0.0.0.0:${PORT}`)
);
