const express = require("express");
const path = require("path");
const sqlite3 = require("sqlite3").verbose();
const bodyParser = require("body-parser");
const cors = require("cors");
const { v4: uuidv4 } = require("uuid");
const http = require("http");
const { Server } = require("socket.io");

const app = express();
const PORT = 3000;
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: "*", // Allow all origins
        methods: ["GET", "POST", "PUT", "DELETE"]
    }
});

// Middleware
app.use(cors());
app.use(bodyParser.json());


// Serve static files from the public directory
app.use(express.static(path.join(__dirname, "public"), {
    setHeaders: (res, path, stat) => {
        if (path.endsWith(".html")) {
            res.setHeader("Content-Type", "text/html; charset=UTF-8");
        }
    }
}));


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

// Fetch all products
app.get("/products", (req, res) => {
    db.all("SELECT * FROM products", [], (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json(rows);
    });
});

// Add new product
app.post("/products", (req, res) => {
    const { name, price, qrCode, imagePath } = req.body;
    if (!name || !price) {
        return res.status(400).json({ error: "Name and Price are required!" });
    }

    const id = uuidv4();
    db.run(
        `INSERT INTO products (id, name, price, qrCode, imagePath) VALUES (?, ?, ?, ?, ?)`,
        [id, name, price, qrCode, imagePath],
        function (err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            // Notify all connected clients
            io.emit("productUpdated", { action: "added", id, name, price });
            res.json({ id, name, price, qrCode, imagePath });
        }
    );
});

// Update product
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
            // Notify all connected clients
            io.emit("productUpdated", { action: "updated", id, name, price });
            res.json({ message: "Product updated successfully" });
        }
    );
});

// Delete product
app.delete("/products/:id", (req, res) => {
    const { id } = req.params;

    db.run(`DELETE FROM products WHERE id = ?`, [id], function (err) {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        // Notify all connected clients
        io.emit("productUpdated", { action: "deleted", id });
        res.json({ message: "Product deleted successfully" });
    });
});

// Serve index.html when accessing the root URL
app.get("/", (req, res) => {
    res.setHeader("Content-Type", "text/html");
    res.sendFile(path.join(__dirname, "public", "index.html"));
});

// Start server with WebSocket support
server.listen(PORT, () => {
    console.log(`🚀 Server running at http://localhost:${PORT}`);
});
