import * as admin from "firebase-admin";
import { HttpsError } from "firebase-functions/v2/https";
import { User } from "../model/User";
import { UserRepository } from "../repository/user.repository";

const VALID_ROLES: readonly string[] = ["user", "editor", "admin"];

export const UserService = {

  setUserRole: async (
    caller: User,
    targetUid: string,
    role: string,
    operationsCities?: Record<string, string>
  ): Promise<void> => {
    if (!targetUid || targetUid.trim() === "") {
      throw new HttpsError("invalid-argument", "Invalid User ID.");
    }

    if (!role || !VALID_ROLES.includes(role)) {
      throw new HttpsError(
        "invalid-argument",
        `Invalid role: '${role}'.`
      );
    }

    const userRecord = await admin.auth().getUser(targetUid);
    const existingClaims = userRecord.customClaims || {};

    await admin.auth().setCustomUserClaims(targetUid, {
      ...existingClaims,
      role: role
    });

    await UserRepository.updateUserRole(
      targetUid,
      role,
      caller.email,
      operationsCities
    );
  },
};
