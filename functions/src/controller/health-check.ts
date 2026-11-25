import { onRequest } from "firebase-functions/v2/https";

export const healthCheck = onRequest((request, response) => {
  response.status(200).json({
    status: "ok",
    message: "Service is running"
  });
});