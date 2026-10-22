export type UserRole = "user" | "editor" | "admin";

export interface User {
  readonly uid: string;
  readonly email: string;
  readonly role: UserRole;
  readonly name?: string;
  readonly operationsCities?: Record<string, string>;
  readonly roleUpdatedAt?: Date;
  readonly roleUpdatedBy?: string;
}