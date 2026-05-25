# Eventos Académicos

Aplicación de gestión de eventos académicos (conferencias, seminarios, talleres). Backend Node.js/Express + PostgreSQL. Frontend móvil en Flutter (código en `flutter_app/`).

## Run & Operate

- `pnpm --filter @workspace/api-server run dev` — run the API server (port 5000)
- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from the OpenAPI spec
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)
- `pnpm --filter @workspace/scripts run seed` — seed initial categories, locations and sample events
- Required env: `DATABASE_URL` — Postgres connection string, `SESSION_SECRET` — JWT signing secret

## Stack

- pnpm workspaces, Node.js 24, TypeScript 5.9
- API: Express 5 + JWT auth (jsonwebtoken) + bcryptjs
- DB: PostgreSQL + Drizzle ORM
- Validation: Zod (`zod/v4`), `drizzle-zod`
- API codegen: Orval (from OpenAPI spec)
- Build: esbuild (CJS bundle)
- Mobile: Flutter (Dart) — see `flutter_app/`

## Where things live

- `lib/api-spec/openapi.yaml` — OpenAPI spec (source of truth)
- `lib/db/src/schema/` — Drizzle table definitions (users, categories, locations, events, schedules, registrations)
- `artifacts/api-server/src/routes/` — Express route handlers
- `flutter_app/` — Complete Flutter mobile app source code
- `flutter_app/lib/config.dart` — Backend URL config (change this after deploying)
- `flutter_app/README.md` — Flutter setup instructions and full API docs

## Architecture decisions

- JWT-based auth: stateless, easy for mobile clients. Token stored in SharedPreferences on Flutter side.
- 5 domain tables (categories, locations, events, schedules, registrations) + users for auth.
- OpenAPI-first: all route validation uses generated Zod schemas from `@workspace/api-zod`.
- Flutter app uses a singleton ApiService with in-memory token caching for clean state management.

## Product

- Auth: register and login with email/password
- Events: list, search/filter, create, edit, delete academic events
- Schedules: agenda sessions per event (speaker, time, room)
- Registrations: users can register/cancel for events
- Categories & Locations: supporting entities for event classification

## User preferences

- Project is a university final project for "Programación para Dispositivos Móviles"
- Backend: Express + PostgreSQL on Replit
- Frontend: Flutter (not Expo/React Native — Flutter specifically required by the course)

## Gotchas

- Always run `pnpm --filter @workspace/api-spec run codegen` after changing the OpenAPI spec
- Always run `pnpm --filter @workspace/db run push` after changing schema files
- Flutter app URL must be updated in `flutter_app/lib/config.dart` after deploying the backend
- The `lib/api-zod/src/index.ts` only exports from `./generated/api` (not types) to avoid duplicate exports

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
- Flutter README: `flutter_app/README.md`
