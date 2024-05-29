const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const app = express();
const port = 3000;

// 在根路径返回 Hello World
app.get('/', (req, res) => {
  res.send('Hello World');
});

// 代理设置
const options = {
  target: 'http://localhost:8443', // 目标服务器
  changeOrigin: true,              // 修改请求头中的Host为目标服务器
  ws: true,                        // 启用WebSocket代理
  pathRewrite: {
    '^/': '/ray272449844', // 可选：重写路径，例如/api -> /
  },
  onProxyReq: (proxyReq, req, res) => {
    // 在代理请求发送到目标服务器之前执行一些操作
  },
  onProxyRes: (proxyRes, req, res) => {
    // 在代理响应返回给客户端之前执行一些操作
  },
  onError: (err, req, res) => {
    res.status(500).json({ error: 'Proxy error', details: err });
  }
};

// 代理所有除了根路径之外的请求
app.use((req, res, next) => {
  if (req.path !== '/') {
    createProxyMiddleware(options)(req, res, next);
  } else {
    next();
  }
});

app.listen(port, () => {
  console.log(`Proxy server listening at http://localhost:${port}`);
});
