#!/usr/bin/env node

const { createProxyMiddleware } = require('http-proxy-middleware');
const http = require('http');
const express = require('express');
const app = express();

// 创建代理中间件，转发到目标服务器8080
const proxy = createProxyMiddleware({
    target: 'http://127.0.0.1:8080',
    changeOrigin: true,
    ws: true,
    logLevel: 'info',
});

// 使用代理中间件
app.use('/', proxy);

// 启动服务器
const port = 3000;

http.createServer(app).listen(port, () => {
    console.log(`Proxy server started on port ${port}`);
});
