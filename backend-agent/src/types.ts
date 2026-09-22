export type UserRole = "OWNER" | "CASHIER";

export interface AuthorizedUser {
  phone: string;
  userId: string;
  storeId: string;
  role: UserRole;
}

export interface AgentContext extends AuthorizedUser {
  whatsappMessageId: string;
}

export interface DateRange {
  from: Date;
  to: Date;
  label: string;
}

export interface IncomingTextMessage {
  id: string;
  from: string;
  text: string;
}

