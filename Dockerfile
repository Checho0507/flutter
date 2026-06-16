FROM node:18-slim

# Instalar pnpm
RUN npm install -g pnpm@9.0.0

WORKDIR /app

# Copiar archivos de configuración del monorepo
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Copiar todos los package.json de los workspaces
COPY artifacts/api-server/package.json ./artifacts/api-server/
COPY lib/api-zod/package.json ./lib/api-zod/
COPY lib/db/package.json ./lib/db/
# Si hay más workspaces, añádelos aquí

# Instalar dependencias (solo las necesarias para producción)
RUN pnpm install --frozen-lockfile --prod=false

# Copiar todo el código fuente
COPY . .

# Build del api-server
RUN pnpm --filter @workspace/api-server build

# Puerto para Railway
EXPOSE 3000

# Iniciar el servidor
CMD ["pnpm", "--filter", "@workspace/api-server", "start"]