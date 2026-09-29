import * as admin from "firebase-admin";
import { NewsPackage, newsPackageToFirestore } from "../model/NewsPackage";
import Firestore = admin.firestore.Firestore;

export const NewsRepository = {

  savePackage: async (newsPackage: NewsPackage): Promise<void> => {
    const db: Firestore = admin.firestore();

    try {
      const docRef = db.collection("news")
        .doc(newsPackage.news.id)
        .collection("packages")
        .doc(newsPackage.id);

      await docRef.set(newsPackageToFirestore(newsPackage), { merge: true });
    } catch (e) {
      throw e;
    }
  }
};