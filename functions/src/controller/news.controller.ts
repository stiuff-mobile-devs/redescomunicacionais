import { onCall } from "firebase-functions/https";
import { CallableRequest, HttpsError } from "firebase-functions/v2/https";
import { jsonToNewsPackage } from "../model/NewsPackage";
import { NewsService } from "../service/news.service";
import { getEditorUser } from "../service/auth.service";

export const uploadNewsPackage = onCall<any>(
  async (request: CallableRequest<any>): Promise<{message: string}> => {
    try {
      getEditorUser(request.auth);
      const newsPackage = jsonToNewsPackage(request.data);

      await NewsService.uploadNewsPackage(newsPackage);
      return {
        message: "News package successfully synced."
      }
    } catch (e) {
      throw new HttpsError(
        "internal",
        "Internal server error."
      );
    }
  }
);