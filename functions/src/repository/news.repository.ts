import * as admin from "firebase-admin";
import { NewsPackage, newsPackageToFirestore } from "../model/NewsPackage";
import Firestore = admin.firestore.Firestore;

export const NewsRepository = {

  savePackage: async (newsPackage: NewsPackage): Promise<void> => {
    const db: Firestore = admin.firestore();

    try {
      const newsDocRef = db.collection("news_test").doc(newsPackage.news.id);
      await newsDocRef.set(newsPackageToFirestore(newsPackage), { merge: true });
    } catch (e) {
      throw e;
    }
  }
};