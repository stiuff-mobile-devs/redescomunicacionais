import { setGlobalOptions } from "firebase-functions/v2/options";
import * as admin from "firebase-admin";

admin.initializeApp();

setGlobalOptions({
  region: 'southamerica-east1',
  maxInstances: 10
});

export * from "./controller/health-check";
export * from "./controller/public-key.controller";
export * from "./controller/news.controller";
