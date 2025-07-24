import { prisma } from "../application/database.js";
import { HttpException } from "../middleware/error.js";
import { hash, verify } from "argon2";
import jwt from "jsonwebtoken";
import "dotenv/config";

/**
 * Fungsi untuk registrasi user baru
 */
export const register = async (request) => {
  // Cek apakah username sudah digunakan
  const findUser = await prisma.users.findFirst({
    where: {
      username: request.username,
    },
  });

  if (findUser) {
    throw new HttpException(409, "User already exists");
  }

  // Hash password sebelum disimpan
  const hashedPassword = await hash(request.password);

  // Simpan user baru ke database
  const user = await prisma.users.create({
    data: {
      fullname: request.fullname,
      username: request.username,
      password: hashedPassword,
    },
    select: {
      id: true,
      fullname: true,
      username: true,
      created_at: true,
    },
  });

  return {
    message: "User created successfully",
    user,
  };
};

/**
 * Fungsi untuk login user
 */
export const login = async (request) => {
  // Cari user berdasarkan username
  const user = await prisma.users.findUnique({
    where: {
      username: request.username,
    },
  });

  // Jika user tidak ditemukan
  if (!user) {
    throw new HttpException(401, "Invalid credentials");
  }

  // Verifikasi password
  const isPasswordValid = await verify(user.password, request.password);
  if (!isPasswordValid) {
    throw new HttpException(401, "Invalid credentials");
  }

  // Buat token JWT
  const token = jwt.sign(
    { id: user.id },
    process.env.JWT_KEY,
    { expiresIn: "1d" } // opsional: token berlaku 1 hari
  );

  return {
    message: "Login successful",
    access_token: token,
  };
};
