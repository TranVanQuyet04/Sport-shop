// ws.service.ts
import SockJS from "sockjs-client";
import Stomp from "stompjs";
import { useAuthStore } from "@/store/useAuthStore";

const configuredSocketUrl = import.meta.env.VITE_CHAT_WS_URL?.trim();
const socketServiceBase = (
  import.meta.env.VITE_API_URL?.trim() ||
  import.meta.env.VITE_CHAT_API_URL?.trim() ||
  "http://localhost:8084"
)
  .replace(/\/+$/, "")
  .replace(/\/api$/, "");
const WS_URL = configuredSocketUrl || `${socketServiceBase}/ws/chat`;

class WebSocketClient {
  stomp: any = null;
  connected = false;
  connecting = false;
  subscriptions: Record<string, any> = {};

  connect(onConnected?: () => void, onError?: (err: any) => void) {
    if (this.connected || this.connecting) return;
    this.connecting = true;

    const token = useAuthStore.getState().accessToken;
    const socket = new SockJS(WS_URL);
    this.stomp = Stomp.over(socket);

    this.stomp.connect(
      { Authorization: token ? `Bearer ${token}` : "" },
      () => {
        this.connected = true;
        this.connecting = false;
        console.log("[WS] Connected Success");
        onConnected?.();
      },
      (err: any) => {
        this.connected = false;
        this.connecting = false;
        console.error("[WS] Connection Error:", err);
        onError?.(err);
        // Thử kết nối lại sau 5s
        setTimeout(() => this.connect(onConnected, onError), 5000);
      },
    );
  }

  subscribeRoom(roomId: number, callback: (msg: any) => void) {
    if (!this.stomp || !this.connected) return;
    const path = `/topic/room/${roomId}`;
    if (this.subscriptions[path]) return;

    this.subscriptions[path] = this.stomp.subscribe(path, (msg: any) => {
      callback(JSON.parse(msg.body));
    });
  }

  subscribeNewRoom(callback: (room: any) => void) {
    if (!this.stomp || !this.connected) return;
    const path = "/topic/chat/rooms";
    if (this.subscriptions[path]) return this.subscriptions[path];

    this.subscriptions[path] = this.stomp.subscribe(path, (msg: any) => {
      callback(JSON.parse(msg.body));
    });
    return this.subscriptions[path];
  }

  sendMessage(roomId: number, payload: any) {
    if (this.connected && this.stomp) {
      this.stomp.send(`/app/chat/${roomId}`, {}, JSON.stringify(payload));
    }
  }
}

export const ws = new WebSocketClient();
export default ws;
