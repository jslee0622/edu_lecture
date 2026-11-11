#!/usr/bin/env bash
# dx-app_examples 노트북을 실행할 가상환경(.venv)을 만든다.
#
# 사용법:
#   ./setup_env.sh              # .venv 생성 또는 갱신
#   ./setup_env.sh --recreate   # 기존 .venv 를 지우고 새로 만든다
#
# 환경변수:
#   DX_ALL_SUITE   dx-all-suite 위치 (기본값: $HOME/Workspace/dx-all-suite)
#   VENV_DIR       만들 가상환경 위치 (기본값: <repo>/.venv)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${VENV_DIR:-${REPO_ROOT}/.venv}"

export DX_ALL_SUITE="${DX_ALL_SUITE:-${HOME}/Workspace/dx-all-suite}"

DX_APP="${DX_ALL_SUITE}/dx-runtime/dx_app"
RUNTIME_VENV="${DX_ALL_SUITE}/dx-runtime/venv-dx-runtime"

KERNEL_NAME="dx-app-examples"
KERNEL_DISPLAY="Python (dx-app_examples)"

# 노트북 01~17 이 각각 모델 하나씩 쓴다.
MIN_MODELS=17

RECREATE=0
for arg in "$@"; do
    case "$arg" in
        --recreate) RECREATE=1 ;;
        -h|--help) awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "${BASH_SOURCE[0]}"; exit 0 ;;
        *) echo "알 수 없는 인자: $arg" >&2; exit 2 ;;
    esac
done

info() { printf '\033[92m[INFO]\033[0m  %s\n' "$*"; }
die()  { printf '\033[91m[ERR ]\033[0m  %s\n' "$*" >&2; exit 1; }

# ── 1. dx-all-suite 확인 ──────────────────────────────────────────────────────

[ -d "$DX_APP" ] || die "dx_app 이 없다: ${DX_APP}
  dx-all-suite 를 다른 곳에 두었다면 DX_ALL_SUITE 로 알려 준다:
    DX_ALL_SUITE=/path/to/dx-all-suite ./setup_env.sh"

[ -x "${RUNTIME_VENV}/bin/python" ] || die "dx-runtime venv 가 없다: ${RUNTIME_VENV}
  먼저 dx-runtime 을 설치한다:
    cd ${DX_ALL_SUITE}/dx-runtime && ./install.sh"

RUNTIME_PY="${RUNTIME_VENV}/bin/python"

"$RUNTIME_PY" -c 'import dx_engine' 2>/dev/null || die "dx-runtime venv 에 dx_engine 이 없다.
  dx-runtime 설치가 끝나지 않았다. 다시 설치한다:
    cd ${DX_ALL_SUITE}/dx-runtime && ./install.sh"

DX_ENGINE_VER="$("$RUNTIME_PY" -c 'import dx_engine; print(getattr(dx_engine, "__version__", "unknown"))')"
RUNTIME_SITE="$("$RUNTIME_PY" -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')"
RUNTIME_PYVER="$("$RUNTIME_PY" -c 'import sys; print("%d.%d" % sys.version_info[:2])')"

info "dx-all-suite : ${DX_ALL_SUITE}"
info "dx-runtime   : dx_engine ${DX_ENGINE_VER} / Python ${RUNTIME_PYVER}"

# ── 2. 같은 Python 마이너 버전 찾기 ───────────────────────────────────────────

BASE_PY=""
for candidate in "python${RUNTIME_PYVER}" python3; do
    if command -v "$candidate" >/dev/null 2>&1; then
        ver="$("$candidate" -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null || true)"
        if [ "$ver" = "$RUNTIME_PYVER" ]; then BASE_PY="$(command -v "$candidate")"; break; fi
    fi
done
[ -n "$BASE_PY" ] || die "Python ${RUNTIME_PYVER} 를 찾을 수 없다.
  dx_engine 확장 모듈이 cp${RUNTIME_PYVER//./} ABI 라 같은 마이너 버전이어야 한다.
    sudo apt install python${RUNTIME_PYVER} python${RUNTIME_PYVER}-venv"

"$BASE_PY" -c 'import venv' 2>/dev/null || die "venv 모듈이 없다:
    sudo apt install python${RUNTIME_PYVER}-venv"

info "base python  : ${BASE_PY}"

# ── 3. 가상환경 생성 ──────────────────────────────────────────────────────────

if [ "$RECREATE" -eq 1 ] && [ -d "$VENV_DIR" ]; then
    info "기존 가상환경 삭제: ${VENV_DIR}"
    rm -rf "$VENV_DIR"
fi

if [ -d "$VENV_DIR" ]; then
    info "기존 가상환경 재사용: ${VENV_DIR}"
else
    info "가상환경 생성: ${VENV_DIR}"
    "$BASE_PY" -m venv "$VENV_DIR"
fi

VENV_PY="${VENV_DIR}/bin/python"

# ── 4. dx-runtime site-packages 연결 ──────────────────────────────────────────

VENV_SITE="$("$VENV_PY" -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')"
PTH_FILE="${VENV_SITE}/zz-dx-runtime.pth"
printf '%s\n' "$RUNTIME_SITE" > "$PTH_FILE"
info "dx-runtime 연결"

# ── 5. 패키지 설치 ────────────────────────────────────────────────────────────
NEED_NUMPY=""
"$VENV_PY" -c 'import numpy' 2>/dev/null || NEED_NUMPY="numpy"

info "pip 업그레이드"
"$VENV_PY" -m pip install --quiet --upgrade pip wheel

info "노트북 의존성 설치"
"$VENV_PY" -m pip install --quiet -r "${REPO_ROOT}/requirements.txt" ${NEED_NUMPY}

# ── 6. activate 에 DX_ALL_SUITE 심기 ──────────────────────────────────────────

ACTIVATE="${VENV_DIR}/bin/activate"
MARKER="# --- dx-app_examples: setup_venv.sh ---"
if ! grep -qF "$MARKER" "$ACTIVATE"; then
    {
        printf '\n%s\n' "$MARKER"
        printf 'export DX_ALL_SUITE="%s"\n' "$DX_ALL_SUITE"
    } >> "$ACTIVATE"
fi

# ── 7. Jupyter 커널 등록 ──────────────────────────────────────────────────────
# --sys-prefix 로 venv 안에 등록한다. --user 는 ~/.local 에 커널 이름당 슬롯 하나를
# 쓰므로, repo 를 두 곳에 클론하면 나중에 setup 한 쪽이 앞선 쪽의 경로를 덮어쓴다.

# 예전 버전이 --user 로 등록해 둔 것이 남아 있으면 sys-prefix 쪽을 가린다.
STALE_KERNEL="${HOME}/.local/share/jupyter/kernels/${KERNEL_NAME}"
if [ -d "$STALE_KERNEL" ]; then
    info "예전 --user 커널 제거: ${STALE_KERNEL}"
    rm -rf "$STALE_KERNEL"
fi

info "Jupyter 커널 등록: ${KERNEL_NAME}"
"$VENV_PY" -m ipykernel install --sys-prefix \
    --name "$KERNEL_NAME" --display-name "$KERNEL_DISPLAY" >/dev/null

"$VENV_PY" - "$KERNEL_NAME" <<'PY'
import json, os, sys
from jupyter_client.kernelspec import KernelSpecManager

resource_dir = KernelSpecManager().get_kernel_spec(sys.argv[1]).resource_dir
path = os.path.join(resource_dir, "kernel.json")
with open(path, encoding="utf-8") as fp:
    spec = json.load(fp)
spec.setdefault("env", {})["DX_ALL_SUITE"] = os.environ["DX_ALL_SUITE"]
with open(path, "w", encoding="utf-8") as fp:
    json.dump(spec, fp, indent=1)
    fp.write("\n")
PY

# ── 8. 검증 ───────────────────────────────────────────────────────────────────

info "검증"
REPO_ROOT="$REPO_ROOT" DX_APP="$DX_APP" MIN_MODELS="$MIN_MODELS" "$VENV_PY" - <<'PY'
import os
import sys
from pathlib import Path

failed = []

for name in ("numpy", "cv2", "matplotlib", "dx_engine"):
    try:
        mod = __import__(name)
        print(f"  {name:12s} {getattr(mod, '__version__', '?')}")
    except Exception as exc:  # noqa: BLE001
        failed.append(f"{name}: {exc}")

need = int(os.environ["MIN_MODELS"])
models = Path(os.environ["REPO_ROOT"]) / "assets" / "models"
n = len(list(models.glob("*.dxnn"))) if models.is_dir() else 0
print(f"  {'models':12s} {n} 개 ({models})")
if n < need:
    failed.append(f"모델이 부족하다 ({n}/{need}). {models} 에 .dxnn 파일을 채운다.")

dx_app = Path(os.environ["DX_APP"])
if not (dx_app / "sample" / "img" / "sample_dog.jpg").is_file():
    failed.append(f"샘플 이미지가 없다: {dx_app}/sample/img — dx_app 저장소를 다시 받는다.")

if not Path("/dev/dxrt0").exists():
    print("  device       /dev/dxrt0 없음 — NPU 드라이버 미적재 (추론 셀은 실패한다)")

if failed:
    print("\n실패:", file=sys.stderr)
    for item in failed:
        print(f"  - {item}", file=sys.stderr)
    sys.exit(1)
PY

cat <<EOF

$(info "완료")

  가상환경   ${VENV_DIR}
  커널 이름  ${KERNEL_DISPLAY}

  Jupyter 실행:
    ./run.sh
EOF
