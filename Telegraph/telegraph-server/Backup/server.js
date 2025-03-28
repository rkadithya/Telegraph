const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const bodyParser = require("body-parser");
const cors = require("cors");
const { v4: uuidv4 } = require("uuid");

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// SQLite Database
const db = new sqlite3.Database("./products.db", (err) => {
    if (err) {
        console.error("Error opening database:", err.message);
    } else {
        console.log("Connected to SQLite database.");
        db.run(`
            CREATE TABLE IF NOT EXISTS products (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                price REAL NOT NULL,
                qrCode TEXT,
                imagePath TEXT
            )
        `);
    }
});

// Fetch all products (GET /products)
app.get("/products", (req, res) => {
    db.all("SELECT * FROM products", [], (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json(rows);
    });
});

// Add new product (POST /products)
app.post("/products", (req, res) => {
    const { name, price, qrCode, imagePath } = req.body;
    if (!name || !price) {
        return res.status(400).json({ error: "Name and Price are required!" });
    }

    const id = uuidv4(); // Generate a new UUID

    db.run(
        `INSERT INTO products (id, name, price, qrCode, imagePath) VALUES (?, ?, ?, ?, ?)`,
        [id, name, price, qrCode, imagePath],
        function (err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            res.json({ id, name, price, qrCode, imagePath });
        }
    );
});

// Update product (PUT /products/:id)
app.put("/products/:id", (req, res) => {
    const { id } = req.params;
    const { name, price, qrCode, imagePath } = req.body;

    db.run(
        `UPDATE products SET name = ?, price = ?, qrCode = ?, imagePath = ? WHERE id = ?`,
        [name, price, qrCode, imagePath, id],
        function (err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            res.json({ message: "Product updated successfully" });
        }
    );
});

// Delete product (DELETE /products/:id)
app.delete("/products/:id", (req, res) => {
    const { id } = req.params;

    db.run(`DELETE FROM products WHERE id = ?`, [id], function (err) {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ message: "Product deleted successfully" });
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Server running at http://localhost:${PORT}`);
});
