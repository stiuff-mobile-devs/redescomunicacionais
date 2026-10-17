import {HttpsError} from "firebase-functions/v2/https";
import {PublicKey} from "../model/PublicKey";
import {User} from "../model/User";
import {PublicKeyRepository} from "../repository/public-key.repository";
import {PackageService} from "./package.service";
import {KeysPackageJson, keysPackageToJson} from "../model/KeysPackage";

export const PublicKeyService = {

  saveNewKey: async (data: PublicKey, loggedUser: User, serverPrivateKey: string): Promise<void> => {
    if (data.email !== loggedUser.email || data.id !== loggedUser.email) {
      throw new HttpsError("permission-denied", "Key does not belong to this user.");
    }

    const existingKey = await PublicKeyRepository.getByEmail(loggedUser.email);

    if (existingKey) {
      if (!existingKey.oldPublicKeys) {
        existingKey.oldPublicKeys = [];
      }

      // adiciona o elemento no início do array
      // chaves mais antigas vão para o final
      existingKey.oldPublicKeys.unshift(existingKey.publicKey);
      existingKey.publicKey = data.publicKey;

      if (data.cities) {
        existingKey.cities = data.cities;
      }

      existingKey.lastUpdated = new Date();
      await PublicKeyRepository.save(existingKey, loggedUser);
    } else {
      await PublicKeyRepository.save(data, loggedUser);
    }

    await PublicKeyService.updatePublicKeysPackage(serverPrivateKey);
  },

  getPublicKeysPackage: async (): Promise<KeysPackageJson> => {
    const keysPackage = await PublicKeyRepository.getPackage();

    if (!keysPackage) {
      throw new HttpsError("not-found", "Keys package not found.");
    }

    return keysPackageToJson(keysPackage);
  },

  updatePublicKeysPackage: async (privateKey: string): Promise<void> => {
    const publicKeys = await PublicKeyRepository.getAll();

    const keysPackage = PackageService.createKeysPackage(
      publicKeys,
      "INTERNAL_API",
      privateKey
    );

    await PublicKeyRepository.savePackage(keysPackage);
  }
};