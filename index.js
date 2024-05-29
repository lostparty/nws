const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const app = express();
const port = 3000;

// 在根路径返回 Hello World
app.get('/', (req, res) => {
  res.send('Hello World');
});

app.use('/', createProxyMiddleware({
  target: 'http://127.0.0.1:8080/', // 需要跨域处理的请求地址
  ws: true, // 是否代理websocket
  changeOrigin: true, // 是否需要改变原始主机头为目标URL,默认false
  onProxyRes: function(proxyRes, req, res) { // 处理代理请求
    // console.log('RAW Response from the target', JSON.stringify(proxyRes.headers, true, 2)); //for debug
    // console.log(req) //for debug
    // console.log(res) //for debug
  },
  onProxyReq: function(proxyReq, req, res) { // 处理代理响应
    // console.log(proxyReq); //for debug
    // console.log(req) //for debug
    // console.log(res) //for debug
  },
  onError: function(err, req, res) { // 处理异常
    console.warn('websocket error.', err);
  },
  pathRewrite: {
    '^/': '/', // 去除请求中的斜线号
  },
  logLevel: 'debug' // 是否打开log日志
}));

app.listen(port, () => {
  console.log(`Proxy server listening at http://localhost:${port}`);
});
