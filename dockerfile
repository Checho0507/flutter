FROM node:18-slim

# Instalar pnpm
RUN npm install -g pnpm@9.0.0

WORKDIR /app

# Copiar archivos de configuración del monorepo
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY artifacts/api-server/package.json ./artifacts/api-server/
COPY lib/api-zod/package.json ./lib/api-zod/
COPY lib/db/package.json ./lib/db/

# Instalar dependencias
RUN pnpm install --frozen-lockfile

# Copiar todo el código
COPY . .

# Build del api-server
RUN pnpm --filter @workspace/api-server build

# Puerto de Railway
EXPOSE 3000

# Iniciar el servidor
CMD ["pnpm", "--filter", "@workspace/api-server", "start"]