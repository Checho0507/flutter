// routes/registrations.ts
import { Router, type IRouter } from "express";
import { db } from "@workspace/db";
import { registrationsTable, eventsTable } from "@workspace/db";
import { eq } from "drizzle-orm";
import { CreateRegistrationBody } from "@workspace/api-zod";

const router: IRouter = Router();

// ✅ CORREGIDO: Usar "/" en lugar de "/registrations"
// Ruta: GET /api/registrations?userId=123
router.get("/", async (req, res): Promise<void> => {
  const { userId } = req.query;
  
  if (!userId) {
    res.status(400).json({ error: "userId is required" });
    return;
  }

  const userIdNum = Number(userId);
  if (isNaN(userIdNum)) {
    res.status(400).json({ error: "userId must be a number" });
    return;
  }

  try {
    console.log(`📡 GET /api/registrations?userId=${userIdNum}`);
    
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
      .where(eq(registrationsTable.userId, userIdNum))
      .orderBy(registrationsTable.registeredAt);

    console.log(`✅ ${rows.length} registraciones encontradas`);
    res.json(rows);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al cargar registraciones' });
  }
});

// ✅ CORREGIDO: Usar "/" en lugar de "/registrations"
// Ruta: POST /api/registrations
router.post("/", async (req, res): Promise<void> => {
  console.log('📡 POST /api/registrations');
  
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
    
    console.log(`✅ Registración creada: ${registration.id}`);
    res.status(201).json(registration);
  } catch (err: unknown) {
    const e = err as { code?: string };
    if (e.code === "23505") {
      res.status(409).json({ error: "Already registered for this event" });
      return;
    }
    console.error('❌ Error:', err);
    res.status(500).json({ error: 'Error al crear registración' });
  }
});

// ✅ CORREGIDO: Usar "/:id" en lugar de "/registrations/:id"
// Ruta: DELETE /api/registrations/:id
router.delete("/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  if (isNaN(id)) {
    res.status(400).json({ error: "ID inválido" });
    return;
  }

  try {
    console.log(`📡 DELETE /api/registrations/${id}`);
    
    const [reg] = await db
      .delete(registrationsTable)
      .where(eq(registrationsTable.id, id))
      .returning();

    if (!reg) {
      res.status(404).json({ error: "Registration not found" });
      return;
    }
    
    console.log(`✅ Registración ${id} eliminada`);
    res.sendStatus(204);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al eliminar registración' });
  }
});

export default router;