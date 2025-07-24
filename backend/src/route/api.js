import { Router } from "express";
import { authController } from "../controllers/auth.js";
import { notesController } from "../controllers/notes.js";
import { profileController } from "../controllers/profile.js";
import { authHandler } from "../middleware/auth.js";

export const router = Router();

// Auth
router.post("/register", authController.register);
router.post("/login", authController.login);

// Middleware Auth (wajib sebelum akses private route)
router.use(authHandler);

// Notes routes
router.get("/notes", notesController.get);
router.get("/notes/:id", notesController.getOne);
router.post("/notes", notesController.create);
router.patch("/notes/:id", notesController.update);
router.delete("/notes/:id", notesController.delete); // ✅ sudah benar

// Profile
router.get("/profile", profileController);
