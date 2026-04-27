#!/usr/bin/env bash
set -euo pipefail

container_name="${1:-oracle-free}"
container_workspace="/workspace/altn83-bdd"
bootstrap_script="${container_workspace}/local-test/bootstrap_and_run.sql"
run_suite_script="${container_workspace}/local-test/run_suite.sql"

docker exec -u 0 "${container_name}" bash -lc "rm -rf '${container_workspace}' && mkdir -p /workspace"
docker cp altn83-bdd "${container_name}:/workspace/"
docker exec "${container_name}" bash -lc "sqlplus -s '/ as sysdba' @${bootstrap_script}"
docker exec "${container_name}" bash -lc "sqlplus -s 'NANOORBIT_ADMIN/NanoOrbit123@//localhost:1521/FREEPDB1' @${run_suite_script}"
