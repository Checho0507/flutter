// routes/locations.ts
import { Router, type IRouter } from "express";
import { db } from "@workspace/db";
import { locationsTable } from "@workspace/db";
import { CreateLocationBody } from "@workspace/api-zod";

const router: IRouter = Router();

// ✅ CORREGIDO: Usar "/" en lugar de "/locations"
router.get("/", async (_req, res): Promise<void> => {
  console.log('📡 GET /api/locations');
  try {
    const locations = await db.select().from(locationsTable).orderBy(locationsTable.name);
    console.log(`✅ ${locations.length} locaciones encontradas`);
    res.json(locations);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al cargar locaciones' });
  }
});

// ✅ CORREGIDO: Usar "/" en lugar de "/locations"
router.post("/", async (req, res): Promise<void> => {
  console.log('📡 POST /api/locations');
  const parsed = CreateLocationBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }
  try {
    const [location] = await db.insert(locationsTable).values(parsed.data).returning();
    res.status(201).json(location);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al crear locación' });
  }
});

export default router;