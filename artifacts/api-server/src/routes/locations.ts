import { Router, type IRouter } from "express";
import { db } from "@workspace/db";
import { locationsTable } from "@workspace/db";
import { CreateLocationBody } from "@workspace/api-zod";

const router: IRouter = Router();

router.get("/locations", async (_req, res): Promise<void> => {
  const locations = await db.select().from(locationsTable).orderBy(locationsTable.name);
  res.json(locations);
});

router.post("/locations", async (req, res): Promise<void> => {
  const parsed = CreateLocationBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }
  const [location] = await db.insert(locationsTable).values(parsed.data).returning();
  res.status(201).json(location);
});

export default router;
