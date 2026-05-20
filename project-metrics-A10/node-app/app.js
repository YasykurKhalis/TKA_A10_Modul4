const express = require('express');
const client = require('prom-client');

const app = express();
const port = 3001;

// Create a Registry which registers the metrics
const register = new client.Registry();

// Add a default label which is added to all metrics
register.setDefaultLabels({
  app: 'node-app'
});

// Enable the collection of default metrics
client.collectDefaultMetrics({ register });

// Create a counter metric for HTTP requests
const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

register.registerMetric(httpRequestCounter);

// Middleware to count requests
app.use((req, res, next) => {
  res.on('finish', () => {
    httpRequestCounter.inc({
      method: req.method,
      route: req.path,
      status_code: res.statusCode
    });
  });
  next();
});

// Root endpoint
app.get('/', (req, res) => {
  res.send('<h1>Halo Kicau Mania!</h1><p>Burung gacor siap digantang!</p><p>Refresh halaman ini untuk menambah total kicauan (HTTP requests).</p>');
});

// Metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(port, () => {
  console.log(`Node app listening at http://localhost:${port}`);
});
