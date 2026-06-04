import type {
  RequestOtpResponse,
  VerifyOtpResponse,
  ResendOtpResponse,
} from "./Auth";

export interface AuthState {
  accessToken: string | null;
  refreshToken: string | null; // Dữ liệu chuỗi token
  user: any | null; 
  loading: boolean;

  // OTP state
  currentIdentifier: string | null;
  otpToken: string | null;
  otpSent: boolean;
  otpExpiresAt: string | null;
  isInitialized: boolean;

  setAccessToken: (token: string) => void;
  setRefreshToken: (token: string | null) => void;
  setUser: (user: any) => void;
  setOtpSent: (otpSent: boolean) => void;
  setOtpToken: (token: string | null) => void;
  clearState: () => void;

  // Auth actions
  loginWithEmailPassword: (email: string, password: string) => Promise<any>;
  registerWithEmail: (data: any) => Promise<any>;
  logout: () => Promise<void>;
  getCurrentUser: () => Promise<void>;
  initializeAuth: () => Promise<void>;
  requestOtp: (
    identifier: string,
    fullName?: string,
  ) => Promise<RequestOtpResponse>;
  verifyOtp: (otpCode: string) => Promise<VerifyOtpResponse>;
  resendOtp: () => Promise<ResendOtpResponse>;
  requestPasswordReset: (email: string) => Promise<any>;
  resetPassword: (
    token: string,
    newPassword: string,
    confirmPassword: string,
  ) => Promise<any>;

  // Đổi tên hàm thành refreshAuth để tránh trùng với biến refreshToken ở trên
  refreshAuth: () => Promise<void>; 
}
