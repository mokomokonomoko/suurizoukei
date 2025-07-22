import cv2
import mediapipe as mp
from pythonosc.udp_client import SimpleUDPClient
import time

client = SimpleUDPClient("127.0.0.1", 12000)

mp_pose = mp.solutions.pose
pose = mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)

cap = cv2.VideoCapture(0)

y_history = []
y_last = None
last_jump_time = 0

# 追加：フラグを用意する
cross_sent = False


def is_jump(y):
    global y_history, last_jump_time, y_last
    y_history.append(y)
    if len(y_history) > 10:
        y_history.pop(0)

    y_min = min(y_history)
    y_max = max(y_history)
    y_now = y_history[-1]
    dy_total = y_now - y_min
    dy_instant = abs(y_now - y_last) if y_last is not None else 0
    y_last = y_now

    cooldown = time.time() - last_jump_time
    print(f"y: {y_now:.3f}, dy_total: {dy_total:.3f}, dy_instant: {dy_instant:.3f}, cooldown: {cooldown:.2f}")

    if dy_total > 0.06 and dy_instant > 0.03 and cooldown > 3.0:
        y_history.clear()
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

        right_wrist = landmarks[mp_pose.PoseLandmark.RIGHT_WRIST]
        client.send_message("/wrist", [right_wrist.x, right_wrist.y])
        print(f"/wrist sent: {right_wrist.x:.2f}, {right_wrist.y:.2f}")

        left_wrist = landmarks[mp_pose.PoseLandmark.LEFT_WRIST]
        client.send_message("/leftwrist", [left_wrist.x, left_wrist.y])

        hips_y = [
            landmarks[mp_pose.PoseLandmark.LEFT_HIP].y,
            landmarks[mp_pose.PoseLandmark.RIGHT_HIP].y
        ]
        knees_y = [
            landmarks[mp_pose.PoseLandmark.LEFT_KNEE].y,
            landmarks[mp_pose.PoseLandmark.RIGHT_KNEE].y
        ]
        shoulders_y = [
            landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].y,
            landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].y
        ]
        avg_y = (sum(hips_y) + sum(knees_y) + sum(shoulders_y)) / 6
        # 範囲を現実に合わせて調整
        normalized_y = (avg_y - 1.8) / 0.4
        normalized_y = max(0.0, min(normalized_y, 1.0))
        client.send_message("/hip", normalized_y)
        print(f"/hip sent: {normalized_y:.2f}")
        
        head = landmarks[mp_pose.PoseLandmark.NOSE]
        if is_jump(avg_y):
            print("JUMP DETECTED")
            client.send_message("/jump", [head.x, head.y])
            
            # while cap.isOpened(): の中にある results.pose_landmarks: の下 ↓ に追加
        right_x, right_y = right_wrist.x, right_wrist.y
        left_x, left_y = left_wrist.x, left_wrist.y
        
        dx = abs(right_x - left_x)
        dy = abs(right_y - left_y)
        distance = (dx ** 2 + dy ** 2) ** 0.5
        
        mid_x = (right_x + left_x) / 2
        mid_y = (right_y + left_y) / 2
        
        if distance < 0.01:  # 0.0〜1.0座標なので10px相当→約0.01
            if not cross_sent:
                client.send_message("/cross", [mid_x, mid_y])
                print(f"/cross sent: [{mid_x:.2f}, {mid_y:.2f}]")
                cross_sent = True
            else:
                cross_sent = False

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
