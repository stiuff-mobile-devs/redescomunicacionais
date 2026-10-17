import * as admin from "firebase-admin";
import {PublicKey} from "./PublicKey";

export interface KeysPackage {
  publicKeys: Record<string, string[]>;
  sender: string;
  timestamp: Date;
  signature: string;
}

export interface KeysPackageJson extends Omit<KeysPackage, 'timestamp'> {
  timestamp: string;
}

export function buildPublicKeysMap(data: PublicKey[]): Record<string, string[]> {
  const publicKeys: Record<string, string[]> = {};

  for (const key of data) {
    publicKeys[key.email] = [key.publicKey, ...(key.oldPublicKeys || [])];
  }

  return publicKeys;
}

export function keysPackageToJson(data: KeysPackage): KeysPackageJson {
  return {
    ...data,
    timestamp: data.timestamp.toISOString(),
  };
}

export function keysPackageToFirestore(data: KeysPackage): any {
  return {
    publicKeys: data.publicKeys,
    sender: data.sender,
    timestamp: data.timestamp
      ? admin.firestore.Timestamp.fromDate(data.timestamp)
      : admin.firestore.FieldValue.serverTimestamp(),
    signature: data.signature,
  };
}

export function firestoreToKeysPackage(data: any): KeysPackage {
  return {
    publicKeys: data.publicKeys || {},
    sender: data.sender || "",
    timestamp: data.timestamp ? data.timestamp.toDate() : new Date(),
    signature: data.signature || "",
  };
}

