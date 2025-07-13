# MediaPipe Pose Detection + Processing Animation

MacOSでMediaPipe Pose Landmarkerを使用して腕の動きを検出し、Processingでアニメーション表示するシステムです。

## 環境構築

### 必要なソフトウェア
- Python 3.11
- Processing
- Visual Studio Code（推奨）

### Pythonパッケージのインストール

1. 仮想環境の作成と有効化
```bash
cd pose_detection
python3.11 -m venv pose_env
source pose_env/bin/activate
```

2. 必要なパッケージのインストール
```bash
pip install mediapipe opencv-python python-osc
```

### Processingの設定

1. Processing IDEを開く
2. Sketch > Import Library > Add Library から以下をインストール：
   - oscP5

## 実行手順

1. システム環境設定 > セキュリティとプライバシー > カメラで、Pythonにカメラの使用を許可

2. Processingスケッチの実行
   - Processing IDEで `sketch_250709a.pde` を開く
   - 実行ボタンをクリック

3. Pythonスクリプトの実行
```bash
cd pose_detection
source pose_env/bin/activate
python pose_detector.py
```

## 機能説明

- MediaPipeで右手首の座標を検出
- 検出した座標をOSC通信（ポート12000）でProcessingに送信
- Processingで受信した座標にアニメーションを表示

## 注意事項

- カメラのアクセス権限が必要です
- 必ずProcessingスケッチを先に実行してから、Pythonスクリプトを実行してください