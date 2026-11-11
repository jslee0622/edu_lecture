#!/usr/bin/env bash
# dx-app_examples 노트북을 JupyterLab 으로 띄운다. 먼저 ./setup_env.sh 를 실행한다.
#
#   ./run.sh                           # 로컬 접속
#   ./run.sh --ip 0.0.0.0 --port 9999  # 인자는 jupyter 로 그대로 전달된다

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
exec .venv/bin/jupyter lab notebooks "$@"
