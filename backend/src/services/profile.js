import { prisma } from "../application/database.js";
import { HttpException } from "../middleware/error.js";

export const getProfile = async (userId) => {
  // Cari user berdasarkan ID
  const user = await prisma.users.findUnique({
    where: {
      id: userId,
    },
    select: {
      id: true,
      fullname: true,
      username: true,
      created_at: true,
    },
  });

  // Jika user tidak ditemukan
  if (!user) {
    throw new HttpException(404, "User not found");
  }

  // Kembalikan data user
  return user;
};
