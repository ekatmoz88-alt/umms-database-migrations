#!/usr/bin/env bash
set -Eeuo pipefail

FILES=(
  "db/migrations/V001__init_tables.sql"
  "db/migrations/V002__constraints_and_fk.sql"
  "db/migrations/R__seed_dictionaries.sql"
  "db/tests/integration_test_umms.sql"
  "scripts/run_tests_ci.sh"
  "scripts/verify_bundle.sh"
  "flyway.conf"
  ".gitlab-ci.yml"
)

mkdir -p logs
VERIFY_LOG="logs/verify_psql_$(date +%Y%m%d_%H%M%S).log"
SHA_FILE="${VERIFY_LOG}.sha256"
MARKER_FILE="logs/.last_verified_log"
rm -f "${MARKER_FILE}"

TMP_DB=""
CHECKS_PASSED="false"

exec 3>&1 4>&2
exec > >(tee -a "${VERIFY_LOG}") 2>&1
TEE_PID=$!

cleanup() {
  local status=$?
  trap - EXIT

  if [[ -n "${TMP_DB}" ]]; then
    if sudo -u postgres psql -v ON_ERROR_STOP=1 -c "DROP DATABASE IF EXISTS \"${TMP_DB}\";" >/dev/null 2>&1; then
      echo "Очистка: временная БД \"${TMP_DB}\" удалена."
    else
      echo "ERROR: Не удалось удалить временную БД \"${TMP_DB}\"." >&2
      status=1
    fi
  fi

  exec 1>&3 2>&4
  exec 3>&- 4>&-
  wait "${TEE_PID}" || status=1

  if [[ "${status}" -eq 0 && "${CHECKS_PASSED}" == "true" ]]; then
    printf "%s\n" "${VERIFY_LOG}" > "${MARKER_FILE}"
    echo "=== ВЕРИФИКАЦИЯ КОНТУРА № 2 ЗАВЕРШЕНА УСПЕШНО (КОД 0) ==="
    echo "Протокол сохранён: ${VERIFY_LOG}"
    echo "Контрольные суммы (SHA-256) сохранены: ${SHA_FILE}"
  else
    rm -f "${MARKER_FILE}"
    echo "=== ВЕРИФИКАЦИЯ КОНТУРА № 2 ЗАВЕРШЕНА С ОШИБКОЙ (КОД ${status}) ===" >&2
  fi

  exit "${status}"
}
trap cleanup EXIT

echo "=== 1. Проверка наличия файлов и привязка к версии ==="
for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || { echo "ERROR: Отсутствует файл $f"; exit 1; }
done
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Git commit: $(git rev-parse HEAD)"
else
  echo "Git commit: не инициализирован (локальный каталог)"
fi

echo "=== 2. Контрольные суммы SHA-256 до прогона ==="
HASHES_BEFORE="$(sha256sum "${FILES[@]}")"
echo "${HASHES_BEFORE}"

echo "=== 3. Проверка синтаксиса Bash ==="
bash -n scripts/run_tests_ci.sh
bash -n scripts/verify_bundle.sh
echo "Bash syntax (run_tests_ci.sh, verify_bundle.sh): OK"

echo "=== 4. Проверка базового синтаксиса YAML (.gitlab-ci.yml) ==="
if python3 -c "import yaml" >/dev/null 2>&1; then
  python3 -c "import yaml; yaml.safe_load(open('.gitlab-ci.yml')); print('YAML syntax (PyYAML, без проверки специфических правил GitLab CI): OK')"
else
  echo "YAML syntax: SKIPPED (модуль PyYAML не установлен)"
fi

echo "=== 5. Версия сервера PostgreSQL ==="
sudo -u postgres psql -d postgres -Atc "SELECT version();"

echo "=== 6. Последовательное выполнение декомпозированного SQL-пакета через psql (контур № 2, без Flyway CLI) ==="
TMP_DB="umms_verify_$(date +%s)_$$"
sudo -u postgres psql -v ON_ERROR_STOP=1 -c "CREATE DATABASE \"${TMP_DB}\" OWNER umms_user;"

for sql in \
  db/migrations/V001__init_tables.sql \
  db/migrations/V002__constraints_and_fk.sql \
  db/migrations/R__seed_dictionaries.sql \
  db/tests/integration_test_umms.sql; do
  echo "--- Выполнение через psql: ${sql} ---"
  sudo -u postgres psql -d "${TMP_DB}" -v ON_ERROR_STOP=1 -c "SET ROLE umms_user;" -f "${sql}"
done

echo "=== 7. Контрольные суммы SHA-256 после прогона и сверка неизменности ==="
HASHES_AFTER="$(sha256sum "${FILES[@]}")"
echo "${HASHES_AFTER}"
if [[ "${HASHES_BEFORE}" != "${HASHES_AFTER}" ]]; then
  echo "ERROR: Контрольные суммы файлов изменились во время выполнения проверки!"
  exit 5
fi
printf "%s\n" "${HASHES_AFTER}" > "${SHA_FILE}"
echo "Сверка SHA-256 (до/после): совпадение 100%"

CHECKS_PASSED="true"
