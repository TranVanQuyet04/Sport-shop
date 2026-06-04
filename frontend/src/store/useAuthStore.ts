import { persist } from "zustand/middleware";
import { create } from "zustand";
import api from "@/lib/axios";
import { toast } from "sonner";
import type { AuthState } from "@/types/store";
import type { RegisterResponse } from "@/types/Auth";
import AuthAPI from "@/services/api";

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      accessToken: null,
      refreshToken: null,
      user: null,
      loading: false,
      currentIdentifier: null,
      otpToken: null,
      otpSent: false,
      otpExpiresAt: null,
      isInitialized: false,

      setAccessToken: (token: string) => set({ accessToken: token }),
      setRefreshToken: (token: string | null) => set({ refreshToken: token }),
      setUser: (user) => set({ user }),
      setOtpSent: (otpSent: boolean) => set({ otpSent }),
      setOtpToken: (token: string | null) => set({ otpToken: token }),

      requestOtp: async (identifier: string, fullName?: string) => {
        set({ loading: true });
        try {
          const data = await AuthAPI.requestOtp(identifier, fullName);
          set({
            currentIdentifier: identifier,
            otpToken: data.otpToken ?? null,
            otpExpiresAt: data.expiresAt ?? null,
            otpSent: true,
          });
          toast.success(data.message || "OTP da duoc gui!");
          return data;
        } catch (error: any) {
          toast.error(error.response?.data?.message || "Gui OTP that bai");
          throw error;
        } finally {
          set({ loading: false });
        }
      },

      verifyOtp: async (otpCode: string) => {
        const { otpToken } = get();
        if (!otpToken) {
          throw new Error("No OTP token");
        }

        set({ loading: true });
        try {
          const data = await AuthAPI.verifyOtp(otpToken, otpCode);
          set({
            accessToken: data.accessToken ?? null,
            user: data.user ?? null,
            otpToken: null,
            otpSent: false,
            otpExpiresAt: null,
            currentIdentifier: null,
          });
          toast.success(data.message || "Xac thuc OTP thanh cong!");
          return data;
        } catch (error: any) {
          toast.error(
            error.response?.data?.message || "Xac thuc OTP that bai",
          );
          throw error;
        } finally {
          set({ loading: false });
        }
      },

      resendOtp: async () => {
        const { otpToken } = get();
        if (!otpToken) {
          throw new Error("No OTP token");
        }

        set({ loading: true });
        try {
          const data = await AuthAPI.resendOtp(otpToken);
          set({
            otpToken: data.otpToken ?? otpToken,
            otpExpiresAt: data.expiresAt ?? null,
            otpSent: true,
          });
          toast.success(data.message || "OTP da duoc gui lai!");
          return data;
        } catch (error: any) {
          toast.error(error.response?.data?.message || "Gui lai OTP that bai");
          throw error;
        } finally {
          set({ loading: false });
        }
      },

      // Logic Refresh Token
      refreshAuth: async (): Promise<void> => {
        try {
          const { refreshToken } = get();
          if (!refreshToken) throw new Error("No refresh token");

          const res = await api.post("/api/auth/refresh", { refreshToken });
          const data = res.data;

          if (data?.accessToken) {
            set({
              accessToken: data.accessToken,
              refreshToken: data.refreshToken || refreshToken,
            });
            if (data.user) {
              set({ user: { ...data.user } });
            }
          }
        } catch (error: any) {
          get().clearState();
          throw error;
        }
      },

      initializeAuth: async () => {
        const { accessToken, refreshToken } = get();

        try {
          if (accessToken) {
            await get().getCurrentUser();
          } else if (refreshToken) {
            await get().refreshAuth();
            await get().getCurrentUser();
          }
        } catch (error: any) {
          get().clearState();
        } finally {
          set({ isInitialized: true });
        }
      },

      loginWithEmailPassword: async (email, password) => {
        set({ loading: true });
        try {
          const res = await api.post("/api/auth/login", { email, password });
          const data = res.data;
          if (data.accessToken) {
            set({
              accessToken: data.accessToken,
              refreshToken: data.refreshToken,
              user: data.user,
              loading: false,
            });
            toast.success("Đăng nhập thành công!");

            // Reload lại toàn bộ trang sau khi đăng nhập thành công
            if (typeof window !== "undefined") {
              window.location.reload();
            }
          }
          return data;
        } catch (error: any) {
          set({ loading: false });
          throw error;
        }
      },
      requestPasswordReset: async (email: string) => {
        set({ loading: true });
        try {
          const res = await api.post("/api/auth/forgot-password", {
            email,
          });
          toast.success("Yêu cầu đặt lại mật khẩu đã được gửi!");
          return res.data;
        } catch (error: any) {
          toast.error(
            error.response?.data?.message || "Đặt lại mật khẩu thất bại",
          );
          throw error;
        } finally {
          set({ loading: false });
        }
      },
      resetPassword: async (
        token: string,
        newPassword: string,
        confirmPassword: string,
      ) => {
        set({ loading: true });
        try {
          console.log(newPassword, confirmPassword);

          const res = await api.post("/api/auth/reset-password", {
            token,
            newPassword,
            confirmPassword,
          });
          console.log("Đặt lại mật khẩu thành công:", res);
          toast.success("Đặt lại mật khẩu thành công!");
          if (res.status === 200) {
            window.location.href = "/login";
          }
          return res.data;
        } catch (error: any) {
          toast.error(
            error.response?.data?.message || "Đặt lại mật khẩu thất bại",
          );
          throw error;
        } finally {
          set({ loading: false });
        }
      },
      clearState: () =>
        set({
          accessToken: null,
          refreshToken: null,
          user: null,
          otpToken: null,
          otpSent: false,
          loading: false,
        }),

      // Các hàm khác giữ nguyên logic của bạn...
      registerWithEmail: async (data: {
        email: string;
        password: string;
        full_name: string;
      }): Promise<RegisterResponse> => {
        set({ loading: true });
        try {
          console.log(data);

          const res = await api.post("/api/auth/register", data);
          toast.success("Đăng ký thành công! Vui lòng đăng nhập.");
          return res.data;
        } catch (error: any) {
          toast.error(error.response?.data?.message || "Đăng ký thất bại");
          throw error;
        } finally {
          set({ loading: false });
        }
      },
      logout: async () => {
        try {
          await AuthAPI.logout();
        } catch (error: any) {
          console.error("Lỗi gọi API logout:", error);
        }

        get().clearState();

        useAuthStore.persist.clearStorage();

        localStorage.removeItem("auth-storage");

        // Reload lại toàn bộ trang sau khi đăng xuất
        if (typeof window !== "undefined") {
          window.location.reload();
        }

        if (typeof window !== "undefined") {
          window.location.href = "/login";
        }
      },
      getCurrentUser: async () => {
        try {
          const res = await api.get("/api/user/profile/me");
          // Dựa trên logic của UserAPI.getProfile:
          const userData = res.data?.data ?? res.data;
          console.log("Lấy thông tin người dùng thành công:", userData);

          set({ user: userData });
        } catch (error: any) {
          console.error("Lỗi lấy thông tin người dùng:", error);
          throw error;
        }
      },
    }),
    {
      name: "auth-storage",
      partialize: (state) => ({
        accessToken: state.accessToken,
        refreshToken: state.refreshToken, // Lưu token string vào storage
        user: state.user,
      }),
    },
  ),
);
