// routes/schedules.ts
import { Router, type IRouter } from "express";
import { db } from "@workspace/db";
import { schedulesTable } from "@workspace/db";
import { eq } from "drizzle-orm";
import { CreateScheduleBody } from "@workspace/api-zod";

const router: IRouter = Router();

// ✅ CORREGIDO: Obtener schedules de un evento
// Ruta: GET /api/schedules/event/:eventId
router.get("/event/:eventId", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.eventId) ? req.params.eventId[0] : req.params.eventId;
  const eventId = parseInt(raw, 10);

  if (isNaN(eventId)) {
    res.status(400).json({ error: "ID de evento inválido" });
    return;
  }

  try {
    const schedules = await db
      .select()
      .from(schedulesTable)
      .where(eq(schedulesTable.eventId, eventId))
      .orderBy(schedulesTable.startTime);

    console.log(`✅ ${schedules.length} schedules encontrados para evento ${eventId}`);
    res.json(schedules);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al cargar schedules' });
  }
});

// ✅ CORREGIDO: Crear schedule para un evento
// Ruta: POST /api/schedules/event/:eventId
router.post("/event/:eventId", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.eventId) ? req.params.eventId[0] : req.params.eventId;
  const eventId = parseInt(raw, 10);

  if (isNaN(eventId)) {
    res.status(400).json({ error: "ID de evento inválido" });
    return;
  }

  const parsed = CreateScheduleBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  try {
    const [schedule] = await db
      .insert(schedulesTable)
      .values({ ...parsed.data, eventId })
      .returning();

    console.log(`✅ Schedule creado para evento ${eventId}`);
    res.status(201).json(schedule);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al crear schedule' });
  }
});

// ✅ CORREGIDO: Actualizar schedule
// Ruta: PUT /api/schedules/:id
router.put("/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  if (isNaN(id)) {
    res.status(400).json({ error: "ID inválido" });
    return;
  }

  const parsed = CreateScheduleBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  try {
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
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al actualizar schedule' });
  }
});

// ✅ CORREGIDO: Eliminar schedule
// Ruta: DELETE /api/schedules/:id
router.delete("/:id", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  if (isNaN(id)) {
    res.status(400).json({ error: "ID inválido" });
    return;
  }

  try {
    const [schedule] = await db
      .delete(schedulesTable)
      .where(eq(schedulesTable.id, id))
      .returning();

    if (!schedule) {
      res.status(404).json({ error: "Schedule not found" });
      return;
    }
    res.sendStatus(204);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al eliminar schedule' });
  }
});

export default router;