import { Router, type IRouter } from "express";
import healthRouter from "./health";
import authRouter from "./auth";
import categoriesRouter from "./categories";
import locationsRouter from "./locations";
import eventsRouter from "./events";
import schedulesRouter from "./schedules";
import registrationsRouter from "./registrations";

const router: IRouter = Router();

// Healthcheck sin prefijo (está en /health)
router.use(healthRouter);

// ✅ Agregar prefijos a cada router
router.use("/auth", authRouter);
router.use("/categories", categoriesRouter);
router.use("/locations", locationsRouter);
router.use("/events", eventsRouter);
router.use("/schedules", schedulesRouter);
router.use("/registrations", registrationsRouter);

export default router;