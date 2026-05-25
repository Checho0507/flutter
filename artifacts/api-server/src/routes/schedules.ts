import { Router, type IRouter } from "express";
import { db } from "@workspace/db";
import { schedulesTable } from "@workspace/db";
import { eq } from "drizzle-orm";
import { CreateScheduleBody } from "@workspace/api-zod";

const router: IRouter = Router();

router.get("/events/:id/schedules", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const eventId = parseInt(raw, 10);

  const schedules = await db
    .select()
    .from(schedulesTable)
    .where(eq(schedulesTable.eventId, eventId))
    .orderBy(schedulesTable.startTime);

  res.json(schedules);
});

router.post("/events/:id/schedules", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const eventId = parseInt(raw, 10);

  const parsed = CreateScheduleBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  const [schedule] = await db
    .insert(schedulesTable)
    .values({ ...parsed.data, eventId })
    .returning();

  res.status(201).json(schedule);
});

router.put("/schedules/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  const parsed = CreateScheduleBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  const [schedule] = await db
    .update(schedulesTable)
    .set(parsed.data)
    .where(eq(schedulesTable.id, id))
    .returning();

  if (!schedule) {
    res.status(404).json({ error: "Schedule not found" });
    return;
  }
  res.json(schedule);
});

router.delete("/schedules/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  const [schedule] = await db
    .delete(schedulesTable)
    .where(eq(schedulesTable.id, id))
    .returning();

  if (!schedule) {
    res.status(404).json({ error: "Schedule not found" });
    return;
  }
  res.sendStatus(204);
});

export default router;
