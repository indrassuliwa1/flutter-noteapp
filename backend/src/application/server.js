import express from "express";
import cors from "cors";
import { errorHandler } from "../middleware/error.js";
import { router } from "../route/api.js";

export const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Default Route
app.get("/", (req, res) => {
  res.status(200).json({ message: "Hello World!" });
});

// API Routes
app.use(router);

// Global Error Handler
app.use(errorHandler);
