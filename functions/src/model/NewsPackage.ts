import { News, NewsJson, newsToJson, jsonToNews } from "./News";
import * as admin from "firebase-admin";
export interface NewsPackage {
  id: string;
  news: News;
  sender: string;
  lastUpdated: Date;
  signature: string;
  isUploaded: boolean;
}

export interface NewsPackageJson extends Omit<NewsPackage, 'lastUpdated' | 'news'> {
  news: NewsJson;
  lastUpdated: string;
}

export function newsPackageToJson(data: NewsPackage): NewsPackageJson {
  return {
    ...data,
    news: newsToJson(data.news),
    lastUpdated: data.lastUpdated.toISOString(),
  };
}

export function jsonToNewsPackage(data: any): NewsPackage {
  return {
    ...data,
    news: jsonToNews(data.news),
    lastUpdated: data.lastUpdated ? new Date(data.lastUpdated) : new Date(),
    isUploaded: data.isUploaded ?? false,
  };
}

export function newsPackageToFirestore(data: NewsPackage): any {
  return {
    id: data.id,
    sender: data.sender,
    lastUpdated: data.lastUpdated
      ? admin.firestore.Timestamp.fromDate(data.lastUpdated)
      : admin.firestore.FieldValue.serverTimestamp(),
    signature: data.signature,
    isUploaded: data.isUploaded,
  };
}
