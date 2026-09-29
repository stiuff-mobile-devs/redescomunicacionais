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


