// routes/categories.ts
import { Router, type IRouter } from "express";
import { db } from "@workspace/db";
import { categoriesTable } from "@workspace/db";
import { CreateCategoryBody } from "@workspace/api-zod";

const router: IRouter = Router();

// ✅ CORREGIDO: Usar "/" en lugar de "/categories"
router.get("/", async (_req, res): Promise<void> => {
  console.log('📡 GET /api/categories');
  try {
    const categories = await db.select().from(categoriesTable).orderBy(categoriesTable.name);
    console.log(`✅ ${categories.length} categorías encontradas`);
    res.json(categories);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al cargar categorías' });
  }
});

// ✅ CORREGIDO: Usar "/" en lugar de "/categories"
router.post("/", async (req, res): Promise<void> => {
  console.log('📡 POST /api/categories');
  const parsed = CreateCategoryBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }
  try {
    const [category] = await db.insert(categoriesTable).values(parsed.data).returning();
    res.status(201).json(category);
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ error: 'Error al crear categoría' });
  }
});

export default router;