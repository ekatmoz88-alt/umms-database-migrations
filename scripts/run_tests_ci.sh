#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${PROJECT_ROOT}/logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/ci_run_$(date +%Y%m%d_%H%M%S).log"
export PGHOST="${PGHOST:-postgres}"
export PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-umms_user}"
export PGADMIN_USER="${PGADMIN_USER:-postgres}"
export PGCONNECT_TIMEOUT="${PGCONNECT_TIMEOUT:-5}"
EXPECTED_TABLES="${EXPECTED_TABLES:-24}"
: "${PGPASSWORD:?Ошибка: переменная PGPASSWORD не задана}"
: "${PGADMIN_PASSWORD:?Ошибка: переменная PGADMIN_PASSWORD не задана}"
RAW_SUFFIX="${CI_JOB_ID:-$(date +%s)$$}"
SAFE_SUFFIX="$(printf '%s' "${RAW_SUFFIX}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')"
export PGDATABASE="$(printf 'umms_ci_%s' "${SAFE_SUFFIX}" | cut -c 1-63)"
log() { local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"; echo "${msg}"; echo "${msg}" >> "${LOG_FILE}" || exit 1; }
on_error() { local exit_code=$?; local line_no=$1; trap - ERR; log "ERROR: строка ${line_no}, код ${exit_code}: ${BASH_COMMAND}"; exit "${exit_code}"; }
trap 'on_error $LINENO' ERR
cleanup() {
trap - ERR
log "Очистка: удаление временной БД ${PGDATABASE}..."
PGPASSWORD="${PGADMIN_PASSWORD}" psql -w -h "${PGHOST}" -p "${PGPORT}" -U "${PGADMIN_USER}" -d postgres -v ON_ERROR_STOP=1 -v db_name="${PGDATABASE}" <<'SQL' >/dev/null 2>&1 || true
DROP DATABASE IF EXISTS :"db_name" WITH (FORCE);
SQL
}
trap cleanup EXIT
run_user_psql() { PGPASSWORD="${PGPASSWORD}" psql -w -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${PGDATABASE}" -v ON_ERROR_STOP=1 "$@"; }
log "=== 1. Ожидание готовности сервера PostgreSQL (${PGHOST}:${PGPORT}) ==="
for i in {1..15}; do
if pg_isready -h "${PGHOST}" -p "${PGPORT}" >/dev/null 2>&1; then log "ОК: Сервер PostgreSQL принимает соединения."; break; fi
[[ $i -eq 15 ]] && { log "ERROR: Таймаут ожидания PostgreSQL."; exit 2; }
sleep 1
done
log "=== 2. Проверка прав администратора, создание временной БД и проверка входа ${PGUSER} ==="
CAN_CREATE_DB=$(PGPASSWORD="${PGADMIN_PASSWORD}" psql -w -h "${PGHOST}" -p "${PGPORT}" -U "${PGADMIN_USER}" -d postgres -tA -v ON_ERROR_STOP=1 -c "SELECT (rolcreatedb OR rolsuper)::text FROM pg_roles WHERE rolname = current_user;")
[[ "${CAN_CREATE_DB}" != "true" ]] && { log "ERROR: Роль ${PGADMIN_USER} не имеет прав CREATEDB."; exit 4; }
PGPASSWORD="${PGADMIN_PASSWORD}" psql -w -h "${PGHOST}" -p "${PGPORT}" -U "${PGADMIN_USER}" -d postgres -v ON_ERROR_STOP=1 -v db_name="${PGDATABASE}" -v app_user="${PGUSER}" <<'SQL' >> "${LOG_FILE}" 2>&1
CREATE DATABASE :"db_name" OWNER :"app_user";
SQL
run_user_psql -tA -c "SELECT 'Авторизация успешна: ' || current_user || ' @ ' || current_database();" | tee -a "${LOG_FILE}"
log "=== 3. Накат миграций Flyway ==="
export FLYWAY_URL="jdbc:postgresql://${PGHOST}:${PGPORT}/${PGDATABASE}"
export FLYWAY_USER="${PGUSER}"
export FLYWAY_PASSWORD="${PGPASSWORD}"
export FLYWAY_LOCATIONS="filesystem:${PROJECT_ROOT}/db/migrations"
flyway -configFiles="${PROJECT_ROOT}/flyway.conf" migrate 2>&1 | tee -a "${LOG_FILE}"
log "=== 4. Сверка количества прикладных таблиц (ожидается: ${EXPECTED_TABLES}) ==="
ACTUAL_TABLES=$(run_user_psql -tA -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' AND table_name <> 'flyway_schema_history';")
[[ "${ACTUAL_TABLES}" -ne "${EXPECTED_TABLES}" ]] && { log "ERROR: Ожидалось ${EXPECTED_TABLES} таблиц, найдено ${ACTUAL_TABLES}."; exit 3; }
log "ОК: Структура подтверждена (${ACTUAL_TABLES}/${EXPECTED_TABLES} прикладных таблиц)."
log "=== 5. Запуск интеграционных SQL-тестов ==="
run_user_psql -f "${PROJECT_ROOT}/db/tests/integration_test_umms.sql" 2>&1 | tee -a "${LOG_FILE}"
log "=== ОК: ВСЕ ПРОВЕРКИ УСПЕШНО ЗАВЕРШЕНЫ ==="
