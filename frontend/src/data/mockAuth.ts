import type { User } from "@/types/User";

/**
 * TÃ i khoáº£n áº£o Ä‘á»ƒ test khi chÆ°a cÃ³ backend
 * Chá»‰ hoáº¡t Ä‘á»™ng trong mÃ´i trÆ°á»ng development (npm run dev)
 */

export const MOCK_CREDENTIALS = {
  email: "test@StrideX.vn",
  password: "Test123!",
};

export const MOCK_USER: User = {
  _id: "mock-user-001",
  id: 1,
  fullName: "Nguyá»…n VÄƒn Test",
  full_name: "Nguyá»…n VÄƒn Test",
  email: "test@StrideX.vn",
  phone: "0901234567",
  address: "123 ÄÆ°á»ng ABC, Quáº­n 1, TP.HCM",
  avatarUrl: undefined,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
};

export const MOCK_ACCESS_TOKEN = "mock-access-token-for-dev";

/**
 * Kiá»ƒm tra token cÃ³ pháº£i mock token khÃ´ng
 */
export function isMockToken(token: string | null): boolean {
  return token === MOCK_ACCESS_TOKEN;
}

/**
 * Kiá»ƒm tra credentials cÃ³ khá»›p tÃ i khoáº£n test khÃ´ng
 */
export function isMockCredentials(
  email: string,
  password: string
): boolean {
  return (
    email.toLowerCase().trim() === MOCK_CREDENTIALS.email &&
    password === MOCK_CREDENTIALS.password
  );
}
