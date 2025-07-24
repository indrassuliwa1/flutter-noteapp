import { login, register } from "../services/auth.js";

export const authController = {
  // Controller untuk registrasi user
  register: async (req, res, next) => {
    try {
      const result = await register(req.body);
      return res.status(201).json(result);
    } catch (error) {
      next(error); // lempar ke middleware error handler
    }
  },

  // Controller untuk login user
  login: async (req, res, next) => {
    try {
      const result = await login(req.body);
      return res.status(200).json(result);
    } catch (error) {
      next(error); // lempar ke middleware error handler
    }
  },
};
