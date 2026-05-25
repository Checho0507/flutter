import { Router, type IRouter } from "express";
import { db } from "@workspace/db";
import { eventsTable, categoriesTable, locationsTable, registrationsTable } from "@workspace/db";
import { eq, like, sql, and } from "drizzle-orm";
import { CreateEventBody, UpdateEventBody } from "@workspace/api-zod";

const router: IRouter = Router();

router.get("/events", async (req, res): Promise<void> => {
  const { categoryId, search } = req.query;

  const conditions = [];
  if (categoryId) {
    conditions.push(eq(eventsTable.categoryId, Number(categoryId)));
  }
  if (search && typeof search === "string") {
    conditions.push(like(eventsTable.title, `%${search}%`));
  }

  const rows = await db
    .select({
      id: eventsTable.id,
      title: eventsTable.title,
      description: eventsTable.description,
      startDate: eventsTable.startDate,
      endDate: eventsTable.endDate,
      categoryId: eventsTable.categoryId,
      locationId: eventsTable.locationId,
      organizerId: eventsTable.organizerId,
      maxAttendees: eventsTable.maxAttendees,
      status: eventsTable.status,
      createdAt: eventsTable.createdAt,
      categoryName: categoriesTable.name,
      locationName: locationsTable.name,
      registrationCount: sql<number>`cast(count(${registrationsTable.id}) as int)`,
    })
    .from(eventsTable)
    .leftJoin(categoriesTable, eq(eventsTable.categoryId, categoriesTable.id))
    .leftJoin(locationsTable, eq(eventsTable.locationId, locationsTable.id))
    .leftJoin(registrationsTable, eq(eventsTable.id, registrationsTable.eventId))
    .where(conditions.length > 0 ? and(...conditions) : undefined)
    .groupBy(eventsTable.id, categoriesTable.name, locationsTable.name)
    .orderBy(eventsTable.startDate);

  res.json(rows);
});

router.post("/events", async (req, res): Promise<void> => {
  const parsed = CreateEventBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }
  const [event] = await db.insert(eventsTable).values(parsed.data).returning();
  res.status(201).json(event);
});

router.get("/events/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  const [row] = await db
    .select({
      id: eventsTable.id,
      title: eventsTable.title,
      description: eventsTable.description,
      startDate: eventsTable.startDate,
      endDate: eventsTable.endDate,
      categoryId: eventsTable.categoryId,
      locationId: eventsTable.locationId,
      organizerId: eventsTable.organizerId,
      maxAttendees: eventsTable.maxAttendees,
      status: eventsTable.status,
      createdAt: eventsTable.createdAt,
      categoryName: categoriesTable.name,
      locationName: locationsTable.name,
      registrationCount: sql<number>`cast(count(${registrationsTable.id}) as int)`,
    })
    .from(eventsTable)
    .leftJoin(categoriesTable, eq(eventsTable.categoryId, categoriesTable.id))
    .leftJoin(locationsTable, eq(eventsTable.locationId, locationsTable.id))
    .leftJoin(registrationsTable, eq(eventsTable.id, registrationsTable.eventId))
    .where(eq(eventsTable.id, id))
    .groupBy(eventsTable.id, categoriesTable.name, locationsTable.name);

  if (!row) {
    res.status(404).json({ error: "Event not found" });
    return;
  }
  res.json(row);
});

router.put("/events/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  const parsed = UpdateEventBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  const [event] = await db
    .update(eventsTable)
    .set(parsed.data)
    .where(eq(eventsTable.id, id))
    .returning();

  if (!event) {
    res.status(404).json({ error: "Event not found" });
    return;
  }
  res.json(event);
});

router.delete("/events/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  const [event] = await db
    .delete(eventsTable)
    .where(eq(eventsTable.id, id))
    .returning();

  if (!event) {
    res.status(404).json({ error: "Event not found" });
    return;
  }
  res.sendStatus(204);
});

export default router;
