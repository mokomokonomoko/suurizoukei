import cv2
import mediapipe as mp
from pythonosc import udp_client
import numpy as np

class PoseDetector:
    def __init__(self, osc_ip="127.0.0.1", osc_port=12000):
        # MediaPipeの設定
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        self.mp_draw = mp.solutions.drawing_utils
        
        # OSCクライアントの設定
        self.osc_client = udp_client.SimpleUDPClient(osc_ip, osc_port)
        
        # カメラの設定
        self.cap = cv2.VideoCapture(0)
        
    def run(self):
        while self.cap.isOpened():
            success, image = self.cap.read()
            if not success:
                print("カメラからの映像の取得に失敗しました。")
                continue

            # 画像をRGBに変換
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            
            # ポーズ検出の実行
            results = self.pose.process(image_rgb)
            
            if results.pose_landmarks:
                # 右手首のランドマークを取得 (x, y座標は0-1の範囲で正規化済み)
                right_wrist = results.pose_landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_WRIST]
                
                # OSCで座標を送信
                self.osc_client.send_message("/wrist", [right_wrist.x, right_wrist.y])
                
                # ランドマークの描画
                self.mp_draw.draw_landmarks(
                    image, 
                    results.pose_landmarks, 
                    self.mp_pose.POSE_CONNECTIONS
                )
                
                # 座標をコンソールに表示（デバッグ用）
                print(f"Right Wrist - x: {right_wrist.x:.3f}, y: {right_wrist.y:.3f}")
            
            # 画面表示
            cv2.imshow('MediaPipe Pose', cv2.flip(image, 1))
            
            # ESCキーで終了
            if cv2.waitKey(5) & 0xFF == 27:
                break
                
    def __del__(self):
        self.cap.release()
        cv2.destroyAllWindows()

if __name__ == "__main__":
    detector = PoseDetector()
    detector.run()
