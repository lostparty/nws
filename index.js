const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = 3000;
const FORWARD_PORT = 8080;

app.get('/', (req, res) => {
  res.send('Hello World');
});

app.use(
  '/',
  createProxyMiddleware({
    target: `http://127.0.0.1:${FORWARD_PORT}/`,
    ws: true,
    changeOrigin: true,
    on: {
      proxyRes: function (proxyRes, req, res) {
        // 响应处理逻辑
      },
      proxyReq: function (proxyReq, req, res) {
        // 请求处理逻辑
      },
      error: function (err, req, res) {
        console.warn('WebSocket error.', err);
      }
    },
    pathRewrite: {
      '^/': '/',
    },
    logger: console,
  })
);

app.listen(PORT, () => {
  console.log(`HTTP server running on port ${PORT}`);
});
