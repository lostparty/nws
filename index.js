const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = 3000;
const XRAY_TARGET = 'http://127.0.0.1:8443';  // XRAY服务的地址

// 使用createProxyMiddleware将所有请求转发到XRAY服务
app.use(
  '/',
  createProxyMiddleware({
    target: XRAY_TARGET,
    ws: true,  // 是否代理WebSocket
    changeOrigin: true,  // 是否需要改变原始主机头为目标URL
    pathRewrite: {
      '^/': '/',  // 去除请求中的斜线号
    },
    on: {
      proxyRes: (proxyRes, req, res) => {  // 处理代理请求响应
        console.log('RAW Response from the target:', JSON.stringify(proxyRes.headers, null, 2));  // for debug
      },
      proxyReq: (proxyReq, req, res) => {  // 处理代理请求发出
        console.log('Proxy Request Headers:', JSON.stringify(proxyReq.getHeaders(), null, 2));  // for debug
      },
      error: (err, req, res) => {  // 处理异常
        console.error('Proxy error:', err);
        res.status(500).send('Proxy error');
      }
    },
    logLevel: 'debug',  // 设置日志级别为'debug'以输出详细日志
  })
);

app.listen(PORT, () => {
  console.log(`HTTP server running on port ${PORT}`);
  console.log(`Forwarding requests to XRAY service at ${XRAY_TARGET}`);
});
