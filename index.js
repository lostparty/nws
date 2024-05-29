#!/usr/bin/env node

const { createProxyMiddleware } = require('http-proxy-middleware');
const http = require('http');
const express = require('express');
const app = express();

// 创建简单的Web应用程序，在3000端口返回 "Hello, World!"
const webApp = express();

webApp.get('/', (req, res) => {
    res.send('Hello, World!');
});

webApp.listen(3000, () => {
    console.log('Web server is running on http://127.0.0.1:3000');
});

// 创建代理中间件，转发到目标服务器
const proxy = createProxyMiddleware({
    target: 'http://127.0.0.1:8080',
    changeOrigin: true,
    ws: true,
    logLevel: 'info',
});

// 使用代理中间件
app.use('/', proxy);

http.createServer(app).listen(3000, () => {
    console.log(`Server started on port ${port}`);
});
