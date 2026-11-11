# DX-APP Examples

## 1. 프로젝트 구조

```text
.
├── README.md
├── setup_env.sh                    # 가상환경 생성
├── run.sh                          # JupyterLab 실행
├── notebooks/
│   ├── 00_jupyter_guide/           # 00 jypyter 가이드 노트북
│   ├── 01_….ipynb ~ 17_….ipynb     # 예제 노트북 17편
│   └── resources/                  # 노트북에서 사용하는 이미지 파일
├── assets/
│   └── models/                     # 노트북이 읽는 .dxnn 모델
├── requirements.txt                # 노트북 전용 의존성
└── .venv/                          # 가상환경
```

## 2. 설치

### 2.1 가상 환경 생성

```bash
./setup_env.sh
```

### 2.2 실행

```bash
./run.sh
```

## 3. 예제 문서 목록

|  # | 태스크                | 모델                             | 문서                                                                                                                          |
| -: | --------------------- | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| 01 | Image Classification  | `MobileNetV2`                  | [01_Image_Classification_MobileNetV2.ipynb](./notebooks/01_Image_Classification_MobileNetV2.ipynb)                             |
| 02 | Face Attribute        | `face_attr_resnet_v1_18`       | [02_Face_Attribute_face_attr_resnet_v1_18.ipynb](./notebooks/02_Face_Attribute_face_attr_resnet_v1_18.ipynb)                   |
| 03 | Denoising             | `DnCNN_Gray_Blind`             | [03_Denoising_DnCNN_Gray_Blind.ipynb](./notebooks/03_Denoising_DnCNN_Gray_Blind.ipynb)                                         |
| 04 | Low-light Enhancement | `zero_dce`                     | [04_Low_light_Enhancement_zero_dce.ipynb](./notebooks/04_Low_light_Enhancement_zero_dce.ipynb)                                 |
| 05 | Super Resolution      | `ESPCN_X3`                     | [05_Super_Resolution_ESPCN_X3.ipynb](./notebooks/05_Super_Resolution_ESPCN_X3.ipynb)                                           |
| 06 | Depth Estimation      | `FastDepth_1`                  | [06_Depth_Estimation_FastDepth_1.ipynb](./notebooks/06_Depth_Estimation_FastDepth_1.ipynb)                                     |
| 07 | Face Embedding        | `arcface_mobilefacenet`        | [07_Face_Embedding_arcface_mobilefacenet.ipynb](./notebooks/07_Face_Embedding_arcface_mobilefacenet.ipynb)                     |
| 08 | Person Re-ID          | `casvit_xs`                    | [08_Person_Re_ID_casvit_xs.ipynb](./notebooks/08_Person_Re_ID_casvit_xs.ipynb)                                                 |
| 09 | Hand Landmark         | `HandLandmarkLite_1`           | [09_Hand_Landmark_HandLandmarkLite_1.ipynb](./notebooks/09_Hand_Landmark_HandLandmarkLite_1.ipynb)                             |
| 10 | Semantic Segmentation | `BiSeNetV1`                    | [10_Semantic_Segmentation_BiSeNetV1.ipynb](./notebooks/10_Semantic_Segmentation_BiSeNetV1.ipynb)                               |
| 11 | Face Detection        | `SCRFD500M`                    | [11_Face_Detection_SCRFD500M.ipynb](./notebooks/11_Face_Detection_SCRFD500M.ipynb)                                             |
| 12 | Object Detection      | `YoloV5S`                      | [12_Object_Detection_YoloV5S.ipynb](./notebooks/12_Object_Detection_YoloV5S.ipynb)                                             |
| 13 | PPU Detection         | `YoloV8N_PPU`                  | [13_PPU_Detection_YoloV8N_PPU.ipynb](./notebooks/13_PPU_Detection_YoloV8N_PPU.ipynb)                                           |
| 14 | Human Pose            | `yolov8s_pose`                 | [14_Human_Pose_yolov8s_pose.ipynb](./notebooks/14_Human_Pose_yolov8s_pose.ipynb)                                               |
| 15 | Instance Segmentation | `yolov8s_seg`                  | [15_Instance_Segmentation_yolov8s_seg.ipynb](./notebooks/15_Instance_Segmentation_yolov8s_seg.ipynb)                           |
| 16 | OBB Detection         | `yolo26n-obb`                  | [16_OBB_Detection_yolo26n_obb.ipynb](./notebooks/16_OBB_Detection_yolo26n_obb.ipynb)                                           |
| 17 | 3D Face Alignment     | `3ddfa_v2_mobilnet0.5_120x120` | [17_3D_Face_Alignment_3ddfa_v2_mobilnet0_5_120x120.ipynb](./notebooks/17_3D_Face_Alignment_3ddfa_v2_mobilnet0_5_120x120.ipynb) |
