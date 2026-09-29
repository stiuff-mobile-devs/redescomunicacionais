import { HttpsError } from "firebase-functions/v2/https";
import { NewsPackage } from "../model/NewsPackage";
import { PublicKeyRepository } from "../repository/public-key.repository";
import { PackageService } from "./package.service";
import { NewsRepository } from "../repository/news.repository";

export const NewsService = {

  uploadNewsPackage: async (newsPackage: NewsPackage): Promise<void> => {
    const senderPublicKey = await PublicKeyRepository.getByEmail(newsPackage.sender);

    if (!senderPublicKey) {
      throw new HttpsError("not-found", "Sender public key not found.");
    }

    let isValid = PackageService.verifyNewsPackage(newsPackage, senderPublicKey.publicKey);

    if (!isValid && senderPublicKey.oldPublicKeys && senderPublicKey.oldPublicKeys.length > 0) {
      for (const oldKey of senderPublicKey.oldPublicKeys) {
        if (PackageService.verifyNewsPackage(newsPackage, oldKey)) {
          isValid = true;
          break;
        }
      }
    }

    if (!isValid) {
      throw new HttpsError("permission-denied", "Invalid news package signature.");
    }

    newsPackage.isUploaded = true;
    await NewsRepository.savePackage(newsPackage);
  }
};