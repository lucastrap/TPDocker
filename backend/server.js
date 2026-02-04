const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ message: 'Hello from Backend!', db_status: 'Connected to ' + process.env.DB_HOST });
});

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

const server = app.listen(port, () => {
  console.log(`Backend running on port ${port}`);
});

process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  shutdown();
});

process.on('SIGINT', () => {
    console.log('SIGINT signal received (Ctrl+C): closing HTTP server');
    shutdown();
});

function shutdown() {
    server.close(() => {
        console.log('HTTP server closed');
        process.exit(0);
    });
}
