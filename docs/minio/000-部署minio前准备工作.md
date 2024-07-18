# 部署minio前准备工作

## 准备工作
- minio打算使用"Multi-Node Multi-Drive (MNMD)"模式部署，在部署开始之前，需要部署一个反向代理。
- 反向代理使用nginx，同时考虑到反向代理高可用性，那就使用keepalived实现。

## 部署细节
