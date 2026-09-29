import { KeysService } from './keys.service';
import { KeysPackage } from '../model/KeysPackage';
import { PublicKey } from '../model/PublicKey';
import { NewsPackage } from '../model/NewsPackage';

export const PackageService = {

  verifyKeysPackage: (keysPackage: KeysPackage, publicKeyStr: string): boolean => {
    try {
      const publicKey = KeysService.importPublicKey(publicKeyStr);

      const mapToCheck = {
        publicKeys: keysPackage.publicKeys,
        senderEmail: keysPackage.sender,
        timestamp: keysPackage.timestamp.toISOString()
      };

      const payload = JSON.stringify(mapToCheck);

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
        senderEmail: newsPackage.sender,
        lastUpdated: newsPackage.lastUpdated.toISOString(),
        isUploaded: newsPackage.isUploaded
      };

      const payload = JSON.stringify(mapToCheck);

      return KeysService.toCheck(payload, newsPackage.signature ?? "", publicKey);
    } catch (e) {
      console.error("Error verifying news package:", e);
      return false;
    }
  },

  createKeysPackage: (publicKeys: PublicKey[], sender: string, privateKeyStr: string): KeysPackage => {
    try {
      const privateKey = KeysService.importPrivateKey(privateKeyStr);
      const timestamp = new Date();

      const mapToSign = {
        publicKeys: publicKeys,
        senderEmail: sender,
        timestamp: timestamp.toISOString(),
      };

      const payload = JSON.stringify(mapToSign);
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
