const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const app = express();
const port = 3000;

// 在根路径返回 Hello World
app.get('/', (req, res) => {
  res.send('Hello World');
});

// 代理设置
const proxyOptions = {
  target: 'http://127.0.0.1:8443', // 目标服务器
  changeOrigin: true,              // 修改请求头中的Host为目标服务器
  ws: true,                        // 启用WebSocket代理
  pathRewrite: {
      '^/': '/', /* 去除请求中的斜线号  */
  },
  onProxyReq: (proxyReq, req, res) => {
    // 在代理请求发送到目标服务器之前执行一些操作
    // console.log(proxyReq); // 用于调试
    // console.log(req); // 用于调试
    // console.log(res); // 用于调试
  },
  onProxyRes: (proxyRes, req, res) => {
    // 在代理响应返回给客户端之前执行一些操作
    // console.log('RAW Response from the target', JSON.stringify(proxyRes.headers, true, 2)); // 用于调试
    // console.log(req); // 用于调试
    // console.log(res); // 用于调试
  },
  onError: (err, req, res) => {
    // 处理异常
    console.warn('Proxy error:', err);
    res.status(500).send('Proxy error');
  }
};

// 应用代理中间件，除了根路径外的其他请求
app.use((req, res, next) => {
  if (req.path !== '/') {
    createProxyMiddleware(proxyOptions)(req, res, next);
  } else {
    next();
  }
});

app.listen(port, () => {
  console.log(`Proxy server listening at http://localhost:${port}`);
});
