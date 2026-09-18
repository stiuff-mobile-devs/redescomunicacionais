import * as admin from "firebase-admin";
import { firestore } from "firebase-admin";
import { firestoreToPublicKey, PublicKey, publicKeyToFirestore } from "../model/PublicKey";
import { User } from "../model/User";
import Firestore = firestore.Firestore;

export const PublicKeyRepository = {

  save: async (data: PublicKey, loggedUser: User): Promise<void> => {
    const db: Firestore = admin.firestore();

    try {
      const docRef = db.collection("public_keys");
      await docRef.doc(loggedUser.email).set(publicKeyToFirestore(data), { merge: true });
    } catch (e) {
      throw e;
    }
  },

  getAll: async (): Promise<PublicKey[]> => {
    const db: Firestore = admin.firestore();

    try {
      const snapshot = await db.collection("public_keys").get();
      if (snapshot.empty) {
        return [];
      }

      return snapshot.docs.map((doc) => {
        return firestoreToPublicKey(doc.id, doc.data());
      });
    } catch (e) {
      throw e;
    }
  }
}