import * as admin from "firebase-admin";
import { firestore } from "firebase-admin";
import { firestoreToPublicKey, PublicKey, publicKeyToFirestore } from "../model/PublicKey";
import { User } from "../model/User";
import Firestore = firestore.Firestore;
import { firestoreToKeysPackage, KeysPackage, keysPackageToFirestore } from "../model/KeysPackage";

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

  savePackage: async (data: KeysPackage): Promise<void> => {
    const db: Firestore = admin.firestore();

    try {
      const docRef = db.collection("keys_package");
      await docRef.doc("keys_package").set(keysPackageToFirestore(data), { merge: true });
    } catch (e) {
      throw e;
    }
  },

  getByEmail: async (email: string): Promise<PublicKey | null> => {
    const db: Firestore = admin.firestore();

    try {
      const doc = await db.collection("public_keys").doc(email).get();
      if (!doc.exists) {
        return null;
      }
      return firestoreToPublicKey(doc.id, doc.data()!);
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
  },

  getPackage: async (): Promise<KeysPackage | null> => {
    const db: Firestore = admin.firestore();

    try {
      const doc = await db
        .collection("keys_package")
        .doc("keys_package")
        .get();

      if (!doc.exists) {
        return null;
      }

      return firestoreToKeysPackage(doc.data()!);
    } catch (e) {
      throw e;
    }
  }
}