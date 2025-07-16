import cv2
import mediapipe as mp
from pythonosc.udp_client import SimpleUDPClient
import time

# OSC送信先
client = SimpleUDPClient("127.0.0.1", 12000)

# MediaPipe Pose
mp_pose = mp.solutions.pose
pose = mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)

cap = cv2.VideoCapture(0)

# ジャンプ検知用
y_history = []
last_jump_time = 0


y_last = None  # 前フレーム記憶

def is_jump(y):
    global y_history, last_jump_time, y_last
    y_history.append(y)
    if len(y_history) > 10:
        y_history.pop(0)

    y_min = min(y_history)
    y_max = max(y_history)
    y_now = y_history[-1]
    dy_total = y_now - y_min

    # 前回との差分
    dy_instant = abs(y_now - y_last) if y_last is not None else 0
    y_last = y_now

    cooldown = time.time() - last_jump_time
    print(f"y: {y_now:.3f}, dy_total: {dy_total:.3f}, dy_instant: {dy_instant:.3f}, cooldown: {cooldown:.2f}")

    if dy_total > 0.08 and dy_instant > 0.04 and cooldown > 3.0:
        y_history = []
        last_jump_time = time.time()
        return True
    return False




while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = pose.process(frame_rgb)

    if results.pose_landmarks:
        landmarks = results.pose_landmarks.landmark
        hips_y = [
            landmarks[mp_pose.PoseLandmark.LEFT_HIP].y,
            landmarks[mp_pose.PoseLandmark.RIGHT_HIP].y
        ]
        knees_y = [
            landmarks[mp_pose.PoseLandmark.LEFT_KNEE].y,
            landmarks[mp_pose.PoseLandmark.RIGHT_KNEE].y
        ]

        avg_y = (sum(hips_y) + sum(knees_y)) / 4  # 腰と膝の平均
        if is_jump(avg_y):
            print("JUMP DETECTED")
            client.send_message("/jump", 1)

        annotated = frame.copy()
        mp.solutions.drawing_utils.draw_landmarks(
            annotated, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)
        cv2.imshow("Pose", annotated)
    else:
        cv2.imshow("Pose", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
