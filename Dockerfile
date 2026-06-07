FROM node:24-alpine AS dependencias
WORKDIR /usr/app
RUN corepack enable
COPY package.json pnpm-lock.yaml pnpm.workspace.yaml./
RUN pnpm install --frozen-lockfile

FROM dependencias AS construccion
COPY nest-cli.json tsconfig*.json ./
COPY src ./src
RUN npm run build

FROM node:24-alpine AS dependencias-produccion
WORKDIR /usr/app
RUN corepack enable
COPY package.json pnpm-lock.yaml pnpm.workspace.yaml./
RUN pnpm install --frozen-lockfile --prod

FROM node:24-alpine AS produccion
WORKDIR /usr/app
COPY --from=dependencias-produccion /usr/app/node_modules ./node_modules
COPY --from=construccion /usr/app/dist ./dist
EXPOSE 3000
USER node
CMD ["node", "dist/main.js"]