import { pgTable, serial, timestamp, integer, text, unique } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";
import { usersTable } from "./users";
import { eventsTable } from "./events";

export const registrationsTable = pgTable("registrations", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull().references(() => usersTable.id, { onDelete: "cascade" }),
  eventId: integer("event_id").notNull().references(() => eventsTable.id, { onDelete: "cascade" }),
  registeredAt: timestamp("registered_at", { withTimezone: true }).notNull().defaultNow(),
  status: text("status").notNull().default("confirmed"),
}, (table) => [
  unique("unique_user_event").on(table.userId, table.eventId),
]);

export const insertRegistrationSchema = createInsertSchema(registrationsTable).omit({ id: true, registeredAt: true });
export type InsertRegistration = z.infer<typeof insertRegistrationSchema>;
export type Registration = typeof registrationsTable.$inferSelect;
