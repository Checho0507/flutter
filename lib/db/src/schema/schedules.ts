import { pgTable, text, serial, timestamp, integer } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";
import { eventsTable } from "./events";

export const schedulesTable = pgTable("schedules", {
  id: serial("id").primaryKey(),
  eventId: integer("event_id").notNull().references(() => eventsTable.id, { onDelete: "cascade" }),
  title: text("title").notNull(),
  speaker: text("speaker"),
  startTime: timestamp("start_time", { withTimezone: true }).notNull(),
  endTime: timestamp("end_time", { withTimezone: true }).notNull(),
  room: text("room"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow().$onUpdate(() => new Date()),
});

export const insertScheduleSchema = createInsertSchema(schedulesTable).omit({ id: true, createdAt: true, updatedAt: true });
export type InsertSchedule = z.infer<typeof insertScheduleSchema>;
export type Schedule = typeof schedulesTable.$inferSelect;
