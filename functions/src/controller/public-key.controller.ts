import { onCall } from "firebase-functions/https";
import { getLoggedUser } from "../utils/auth-utils";
import { User } from "../model/User";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {jsonToPublicKey} from "../model/PublicKey";
import { PublicKeyService } from "../service/public-key.service";
import { defineSecret } from "firebase-functions/params";
import { KeysPackageJson} from "../model/KeysPackage";

const apiPrivateKey = defineSecret("API_PRIVATE_KEY");

export const savePublicKey = onCall<any>(
  async (request: CallableRequest<any>): Promise<{message: string}> => {
  try {
    const loggedUser: User = getLoggedUser(request.auth);
    const publicKey = jsonToPublicKey(request.data);

    await PublicKeyService.saveNewKey(publicKey, loggedUser);

    return {
      message: "Public key saved successfully."
    }
  } catch (e) {
    throw new HttpsError(
      "internal",
      "Internal server error."
    );
  }
});

export const getPublicKeysPackage = onCall<any>({ secrets: [apiPrivateKey] },
  async (request: CallableRequest<any>): Promise<KeysPackageJson> => {
    try {
      getLoggedUser(request.auth);
      const privateKeyStr = apiPrivateKey.value();

      return await PublicKeyService.getPublicKeysPackage(privateKeyStr)
    } catch (e) {
      throw new HttpsError(
        "internal",
        "Internal server error."
      );
    }
});
