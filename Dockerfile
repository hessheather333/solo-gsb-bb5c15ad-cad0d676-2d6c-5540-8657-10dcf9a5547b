FROM node:20-alpine

ENV NODE_ENV=production
WORKDIR /app

# 先装依赖，利用镜像层缓存；npm ci 严格按 lockfile 安装，保证可复现
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev

COPY server.js ./
COPY src ./src
COPY public ./public

# 数据目录（可用卷挂载持久化）
ENV DATA_DIR=/app/data
RUN mkdir -p /app/data && chown -R node:node /app
USER node

EXPOSE 3000

# 健康检查：/api/health 返回即视为存活（alpine 自带 busybox wget）
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/api/health || exit 1

CMD ["node", "server.js"]
