import * as admin from "firebase-admin";
import { NewsPackage, newsPackageToFirestore } from "../model/NewsPackage";
import { newsToFirestore } from "../model/News";
import Firestore = admin.firestore.Firestore;

export const NewsRepository = {

  savePackage: async (newsPackage: NewsPackage): Promise<void> => {
    const db: Firestore = admin.firestore();

    try {
      // salva a noticia na colecao 'news'
      const newsDocRef = db.collection("news").doc(newsPackage.news.id);
      await newsDocRef.set(newsToFirestore(newsPackage.news), { merge: true });

      // salva o pacote assinado na subcoleção 'packages'
      const packageDocRef = newsDocRef.collection("packages").doc(newsPackage.id);
      await packageDocRef.set(newsPackageToFirestore(newsPackage), { merge: true });
    } catch (e) {
      throw e;
    }
  }
};