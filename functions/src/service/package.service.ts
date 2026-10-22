import { KeysService } from './keys.service';
import {buildPublicKeysMap, KeysPackage} from '../model/KeysPackage';
import { PublicKey } from '../model/PublicKey';
import { NewsPackage } from '../model/NewsPackage';

export const PackageService = {

  verifyKeysPackage: (keysPackage: KeysPackage, publicKeyStr: string): boolean => {
    try {
      const publicKey = KeysService.importPublicKey(publicKeyStr);

      const mapToCheck = {
        publicKeys: keysPackage.publicKeys,
        sender: keysPackage.sender,
        timestamp: keysPackage.timestamp.toISOString()
      };

      const payload = JSON.stringify(sortMapKeys(mapToCheck));

      return KeysService.toCheck(payload, keysPackage.signature ?? "", publicKey);
    } catch (e) {
      console.error("Error verifying keys package:", e);
      return false;
    }
  },

  verifyNewsPackage: (newsPackage: NewsPackage, publicKeyStr: string): boolean => {
    try {
      const publicKey = KeysService.importPublicKey(publicKeyStr);

      const mapToCheck = {
        id: newsPackage.id,
        news: newsPackage.news,
        email: newsPackage.email,
        lastUpdated: newsPackage.lastUpdated.toISOString(),
      };

      const payload = JSON.stringify(sortMapKeys(mapToCheck));

      return KeysService.toCheck(payload, newsPackage.signature ?? "", publicKey);
    } catch (e) {
      console.error("Error verifying news package:", e);
      return false;
    }
  },

  createKeysPackage: (publicKeysRaw: PublicKey[], sender: string, privateKeyStr: string): KeysPackage => {
    try {
      const privateKey = KeysService.importPrivateKey(privateKeyStr);
      const publicKeys = buildPublicKeysMap(publicKeysRaw);
      const timestamp = new Date();

      const mapToSign = {
        publicKeys: publicKeys,
        sender: sender,
        timestamp: timestamp.toISOString(),
      };

      const payload = JSON.stringify(sortMapKeys(mapToSign));
      const signature = KeysService.toSign(payload, privateKey);

      return {
        publicKeys,
        sender,
        timestamp,
        signature,
      };
    } catch (e) {
      console.error("Error creating keys package:", e);
      throw e;
    }
  }
};

function sortMapKeys(value: any): any {
  if (Array.isArray(value)) {
    return value.map(sortMapKeys);
  }
  if (value !== null && typeof value ===
    "object" && !(value instanceof Date)) {
    return Object.keys(value)
      .sort()
      .reduce((acc: Record<string, any>,
               key) => {
        if (value[key] !== undefined &&
          value[key] !== null) {
          acc[key] =
            sortMapKeys(value[key]);
        }
        return acc;
      }, {});
  }
  return value;
}
