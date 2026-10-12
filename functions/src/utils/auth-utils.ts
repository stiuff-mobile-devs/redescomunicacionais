import { CallableRequest, HttpsError } from "firebase-functions/v2/https";
import { User, UserRole } from "../model/User";

type AuthData = CallableRequest['auth'];

function isAuthenticated(authData?: AuthData): void {
  if (!authData || !authData.token) {
    throw new HttpsError("unauthenticated", "User is not authenticated.");
  }
}

function parseUserRole(role: string): UserRole | undefined {
  if (role === "admin" || role === "editor" || role === "user") {
    return role;
  }
  return undefined;
}

export function getLoggedUser(authData?: AuthData): User {
  isAuthenticated(authData);

  const email = authData!.token.email;
  if (email === null || email === undefined || email.trim() === "") {
    throw new HttpsError("unauthenticated", "Invalid email.");
  }

  return {
    uid: authData!.uid,
    email: email,
    role: parseUserRole(authData!.token.role)
  };
}

export function getAdminUser(authData?: AuthData): User {
  const user = getLoggedUser(authData);
  if (user.role !== "admin") {
    throw new HttpsError("permission-denied", "Only admins can execute this action.");
  }
  return user;
}

export function getEditorUser(authData?: AuthData): User {
  const user = getLoggedUser(authData);
  if (user.role !== "editor") {
    throw new HttpsError("permission-denied", "Only editors can execute this action.");
  }
  return user;
}