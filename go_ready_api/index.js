const express = require("express");
const cors = require("cors");
const bcrypt = require("bcrypt");
const mysql = require("mysql2");

const app = express();

app.use(cors());
app.use(express.json());

// koneksi database
const db = mysql.createPool({
  host: "localhost",
  port: 3306,
  user: "root",
  password: "",
  database: "goready",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

db.getConnection((err, connection) => {
  if (err) {
    console.log("Database gagal terkoneksi:", err.message);
    return;
  }

  console.log("Database berhasil terkoneksi");
  connection.release();
});

// TEST
app.get("/", (req, res) => {
  res.send("API GoReady jalan 🚀");
});

// REGISTER 
app.post("/register", async (req, res) => {
  const { name, email, password } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    const sql = "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";

    db.execute(sql, [name, email, hashedPassword], (err, result) => {
      if (err) {
        console.log("ERROR DB:", err);
        return res.send({ success: false, message: err.message });
      }

      res.send({ success: true, message: "Register berhasil" });
    });
  } catch (err) {
    console.log(err);
    res.send({ success: false, message: "Error hashing password" });
  }
});

//login
app.post("/login", (req, res) => {
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
      res.send({
        success: true,
        message: "Login berhasil",
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
        },
      });
    } else {
      res.send({ success: false, message: "Password salah" });
    }
  });
});

// SAVE TRIP 
app.post("/trip", (req, res) => {
  const { user_id, items } = req.body;

  const values = items.map((item) => [user_id, item]);

  const sql = "INSERT INTO trip_items (user_id, item_name) VALUES ?";

  db.query(sql, [values], (err, result) => {
    if (err) {
      console.log(err);
      return res.send({ success: false });
    }

    res.send({ success: true });
  });
});

// GET TRIP (PER USER) 
app.get("/trip/:user_id", (req, res) => {
  const user_id = parseInt(req.params.user_id);

  console.log("GET TRIP USER:", user_id);

  const sql = "SELECT * FROM trip_items WHERE user_id = ? AND is_found = 0";

  db.execute(sql, [user_id], (err, result) => {
    if (err) {
      console.log("ERROR DB:", err); 
      return res.send({
        success: false,
        message: err.message,
      });
    }

    console.log("RESULT:", result); 

    res.send({
      success: true,
      data: result,
    });
  });
});

// START SERVER 
app.listen(3000, "0.0.0.0", () => {
  console.log("Server berhasil jalan");
});
