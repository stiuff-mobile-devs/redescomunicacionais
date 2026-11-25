import * as admin from "firebase-admin";

export interface News {
  id: string;
  title: string;
  subtitle?: string;
  cities: string[];
  categories: string[];
  body: string;
  urlImages: string[];
  type: string;
  videoUrl?: string;
  
  status: string;
  lastUpdated: Date;
  publicationTerms?: Record<string, any>;
  
  author: string;
  createdBy: string;
  createdAt: Date;

  collaborators?: string[];
  
  validatedBy?: string;
  validatedByName?: string;
  validatedAt?: Date;
  validatedObservation?: string;
  
  rejectedBy?: string;
  rejectedAt?: Date;
  rejectedObservation?: string;
  
  editedAt?: Date;
  excludedBy?: string;
  excludedAt?: Date;
  excludedObservation?: string;
}

type DateFields = 'lastUpdated' | 'createdAt' | 'validatedAt' | 'rejectedAt' | 'editedAt' | 'excludedAt';

export interface NewsJson extends Omit<News, DateFields> {
  lastUpdated: string;
  createdAt: string;
  validatedAt?: string;
  rejectedAt?: string;
  editedAt?: string;
  excludedAt?: string;
}

export function newsToJson(data: News): NewsJson {
  return {
    ...data,
    cities: data.cities || [],
    categories: data.categories || [],
    urlImages: data.urlImages || [],
    lastUpdated: data.lastUpdated.toISOString(),
    createdAt: data.createdAt.toISOString(),
    validatedAt: data.validatedAt ? data.validatedAt.toISOString() : undefined,
    rejectedAt: data.rejectedAt ? data.rejectedAt.toISOString() : undefined,
    editedAt: data.editedAt ? data.editedAt.toISOString() : undefined,
    excludedAt: data.excludedAt ? data.excludedAt.toISOString() : undefined,
  };
}

export function jsonToNews(data: any): News {
  return {
    ...data,
    cities: data.cities || [],
    categories: data.categories || [],
    urlImages: data.urlImages || [],
    lastUpdated: data.lastUpdated ? new Date(data.lastUpdated) : new Date(),
    createdAt: data.createdAt ? new Date(data.createdAt) : new Date(),
    validatedAt: data.validatedAt ? new Date(data.validatedAt) : undefined,
    rejectedAt: data.rejectedAt ? new Date(data.rejectedAt) : undefined,
    editedAt: data.editedAt ? new Date(data.editedAt) : undefined,
    excludedAt: data.excludedAt ? new Date(data.excludedAt) : undefined,
  };
}

export function newsToFirestore(data: News): any {
  const firestoreData: Record<string, any> = {
    id: data.id,
    title: data.title,
    subtitle: data.subtitle,
    body: data.body,
    cities: data.cities || [],
    categories: data.categories || [],
    urlImages: data.urlImages || [],
    videoUrl: data.videoUrl,
    type: data.type,
    status: data.status,
    collaborators: data.collaborators,
    lastUpdated: data.lastUpdated
      ? admin.firestore.Timestamp.fromDate(data.lastUpdated)
      : admin.firestore.FieldValue.serverTimestamp(),
    author: data.author,
    createdBy: data.createdBy,
    createdAt: data.createdAt
      ? admin.firestore.Timestamp.fromDate(data.createdAt)
      : admin.firestore.FieldValue.serverTimestamp(),
    validatedBy: data.validatedBy,
    validatedByName: data.validatedByName,
    validatedAt: data.validatedAt ? admin.firestore.Timestamp.fromDate(data.validatedAt) : undefined,
    validatedObservation: data.validatedObservation,
    rejectedBy: data.rejectedBy,
    rejectedAt: data.rejectedAt ? admin.firestore.Timestamp.fromDate(data.rejectedAt) : undefined,
    rejectedObservation: data.rejectedObservation,
    editedAt: data.editedAt ? admin.firestore.Timestamp.fromDate(data.editedAt) : undefined,
    excludedBy: data.excludedBy,
    excludedAt: data.excludedAt ? admin.firestore.Timestamp.fromDate(data.excludedAt) : undefined,
    excludedObservation: data.excludedObservation,
    publicationTerms: data.publicationTerms,
  };

  Object.keys(firestoreData).forEach((key) => {
    if (firestoreData[key] === undefined) {
      delete firestoreData[key];
    }
  });

  return firestoreData;
}


