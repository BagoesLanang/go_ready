const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const mysql = require('mysql2');

const app = express();

app.use(cors());
app.use(express.json());

// koneksi database
const db = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'goready',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});



// test route
app.get('/', (req, res) => {
  res.send('API GoReady jalan 🚀');
});

app.listen(3000, () => {
  console.log('Server jalan di http://localhost:3000');
});

app.post('/register', async (req, res) => {
  const { email, password } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10); // 🔥 hash

    const sql = "INSERT INTO users (email, password) VALUES (?, ?)";

    db.execute(sql, [email, hashedPassword], (err, result) => {
      if (err) {
        console.log("ERROR DB:", err);
        res.send({ success: false, message: err.message });
      } else {
        res.send({ success: true, message: "Register berhasil" });
      }
    });

  } catch (err) {
    console.log(err);
    res.send({ success: false, message: "Error hashing password" });
  }
});

app.post('/login', (req, res) => {
  const { email, password } = req.body;

  const sql = "SELECT * FROM users WHERE email = ?";

  db.execute(sql, [email], async (err, result) => {
    if (err) {
      console.log("ERROR DB:", err);
      return res.send({ success: false, message: "Login error" });
    }

    if (result.length === 0) {
      return res.send({ success: false, message: "Email tidak ditemukan" });
    }

    const user = result[0];

    const isMatch = await bcrypt.compare(password, user.password);

    if (isMatch) {
      res.send({ success: true, message: "Login berhasil" });
    } else {
      res.send({ success: false, message: "Password salah" });
    }
  });
});