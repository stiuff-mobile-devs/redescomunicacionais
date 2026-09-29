import {PublicKey, PublicKeyJson, publicKeyToJson} from "./PublicKey";

export interface KeysPackage {
  publicKeys: PublicKey[];
  sender: string;
  timestamp: Date;
  signature: string;
}

export interface KeysPackageJson extends Omit<KeysPackage, 'timestamp' | 'publicKeys'> {
  publicKeys: PublicKeyJson[];
  timestamp: string;
}

export function keysPackageToJson(data: KeysPackage): KeysPackageJson {
  return {
    ...data,
    publicKeys: data.publicKeys.map(publicKeyToJson),
    timestamp: data.timestamp.toISOString(),
  };
}