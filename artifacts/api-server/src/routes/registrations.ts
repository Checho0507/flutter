import { Router, type IRouter } from "express";
import { db } from "@workspace/db";
import { registrationsTable, eventsTable } from "@workspace/db";
import { eq } from "drizzle-orm";
import { CreateRegistrationBody } from "@workspace/api-zod";

const router: IRouter = Router();

router.get("/registrations", async (req, res): Promise<void> => {
  const { userId } = req.query;
  if (!userId) {
    res.status(400).json({ error: "userId is required" });
    return;
  }

  const rows = await db
    .select({
      id: registrationsTable.id,
      userId: registrationsTable.userId,
      eventId: registrationsTable.eventId,
      registeredAt: registrationsTable.registeredAt,
      status: registrationsTable.status,
      eventTitle: eventsTable.title,
      eventStartDate: eventsTable.startDate,
      eventEndDate: eventsTable.endDate,
      eventStatus: eventsTable.status,
    })
    .from(registrationsTable)
    .leftJoin(eventsTable, eq(registrationsTable.eventId, eventsTable.id))
    .where(eq(registrationsTable.userId, Number(userId)))
    .orderBy(registrationsTable.registeredAt);

  res.json(rows);
});

router.post("/registrations", async (req, res): Promise<void> => {
  const parsed = CreateRegistrationBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  try {
    const [registration] = await db
      .insert(registrationsTable)
      .values(parsed.data)
      .returning();
    res.status(201).json(registration);
  } catch (err: unknown) {
    const e = err as { code?: string };
    if (e.code === "23505") {
      res.status(409).json({ error: "Already registered for this event" });
      return;
    }
    throw err;
  }
});

router.delete("/registrations/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  const [reg] = await db
    .delete(registrationsTable)
    .where(eq(registrationsTable.id, id))
    .returning();

  if (!reg) {
    res.status(404).json({ error: "Registration not found" });
    return;
  }
  res.sendStatus(204);
});

export default router;
