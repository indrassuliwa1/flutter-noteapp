import { HttpException } from "./error.js";
import jwt from "jsonwebtoken";
import "dotenv/config";

export const authHandler = (req, res, next) => {
  try {
    // Ambil token dari header Authorization (format: Bearer <token>)
    const token = req.headers.authorization?.substring(7); // hapus "Bearer "

    if (!token) {
      throw new HttpException(401, "Unauthorized");
    }

    // Verifikasi token
    jwt.verify(token, process.env.JWT_KEY, (err, decoded) => {
      if (err) {
        return next(new HttpException(401, "Unauthorized"));
      }

      // Simpan user yang ter-decode ke request
      req.user = decoded;
      next();
    });
  } catch (error) {
    next(error);
  }
};
