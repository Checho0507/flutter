import { Router, type IRouter } from "express";
import healthRouter from "./health";
import authRouter from "./auth";
import categoriesRouter from "./categories";
import locationsRouter from "./locations";
import eventsRouter from "./events";
import schedulesRouter from "./schedules";
import registrationsRouter from "./registrations";

const router: IRouter = Router();

router.use(healthRouter);
router.use(authRouter);
router.use(categoriesRouter);
router.use(locationsRouter);
router.use(eventsRouter);
router.use(schedulesRouter);
router.use(registrationsRouter);

export default router;
