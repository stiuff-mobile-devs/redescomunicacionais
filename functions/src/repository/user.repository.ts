import * as admin from "firebase-admin";
import { firestore } from "firebase-admin";
import Firestore = firestore.Firestore;

export const UserRepository = {

  updateUserRole: async (
    targetUid: string,
    role: string,
    adminEmail: string,
    operationsCities?: Record<string, string>
  ): Promise<void> => {
    const db: Firestore = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();

    const userUpdateData: Record<string, any> = {
      role: role,
      operationsCities: operationsCities,
      roleUpdatedBy: adminEmail,
      roleUpdatedAt: now,
      lastUpdated: now
    };

    try {
      await db.collection("users").doc(targetUid).set(userUpdateData, { merge: true });
    } catch (e) {
      throw e;
    }
  }
};
