// routes/events.ts
import { Router, type IRouter } from "express";
import { db } from "@workspace/db";
import { eventsTable, categoriesTable, locationsTable, registrationsTable } from "@workspace/db";
import { eq, like, sql, and } from "drizzle-orm";
import { CreateEventBody, UpdateEventBody } from "@workspace/api-zod";

const router: IRouter = Router();

// ✅ CORREGIDO: Usar "/" en lugar de "/events"
router.get("/", async (req, res): Promise<void> => {
  console.log('📡 GET /api/events');
  const { categoryId, search } = req.query;

  const conditions = [];
  if (categoryId) {
    conditions.push(eq(eventsTable.categoryId, Number(categoryId)));
  }
  if (search && typeof search === "string") {
    conditions.push(like(eventsTable.title, `%${search}%`));
  }

  try {
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

    console.log(`✅ ${rows.length} eventos encontrados`);
    res.json(rows);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al cargar eventos' });
  }
});

// ✅ CORREGIDO: Usar "/" en lugar de "/events"
router.post("/", async (req, res): Promise<void> => {
  console.log('📡 POST /api/events');
  const parsed = CreateEventBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }
  try {
    const [event] = await db.insert(eventsTable).values(parsed.data).returning();
    res.status(201).json(event);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al crear evento' });
  }
});

// ✅ CORREGIDO: Usar "/:id" en lugar de "/events/:id"
router.get("/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  if (isNaN(id)) {
    res.status(400).json({ error: "ID inválido" });
    return;
  }

  try {
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
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al obtener evento' });
  }
});

// ✅ CORREGIDO: Usar "/:id" en lugar de "/events/:id"
router.put("/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  if (isNaN(id)) {
    res.status(400).json({ error: "ID inválido" });
    return;
  }

  const parsed = UpdateEventBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  try {
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
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al actualizar evento' });
  }
});

// ✅ CORREGIDO: Usar "/:id" en lugar de "/events/:id"
router.delete("/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  if (isNaN(id)) {
    res.status(400).json({ error: "ID inválido" });
    return;
  }

  try {
    const [event] = await db
      .delete(eventsTable)
      .where(eq(eventsTable.id, id))
      .returning();

    if (!event) {
      res.status(404).json({ error: "Event not found" });
      return;
    }
    res.sendStatus(204);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al eliminar evento' });
  }
});

export default router;