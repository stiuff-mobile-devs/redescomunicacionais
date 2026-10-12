import { onCall, CallableRequest, HttpsError } from "firebase-functions/v2/https";
import { getAdminUser } from "../utils/auth-utils";
import { UserService } from "../service/user.service";

interface SetUserRoleData {
  targetUid: string;
  role: string;
  operationsCities?: Record<string, string>
}

export const setUserRole = onCall<SetUserRoleData>(
  async (request: CallableRequest<SetUserRoleData>): Promise<{ message: string }> => {
    try {
      const loggedAdmin = getAdminUser(request.auth);
      const { targetUid, role, operationsCities } = request.data || {};

      await UserService.setUserRole(loggedAdmin, targetUid, role, operationsCities);

      return {
        message: `User role successfully updated to '${role}'.`
      };
    } catch (e: any) {
      if (e instanceof HttpsError) {
        throw e;
      }
      throw new HttpsError("internal", e?.message || "Internal server error.");
    }
  }
);
