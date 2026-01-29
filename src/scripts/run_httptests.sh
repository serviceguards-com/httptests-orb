set -euo pipefail

parent_dir="${HTTPTESTS_DIR}"
suite_dir="${parent_dir}/.httptests"

echo "Looking for .httptests in: ${parent_dir}"

# Validate parent directory exists
if [[ ! -d "${parent_dir}" ]]; then
  echo "❌ ERROR: Directory not found: ${parent_dir}"
  exit 1
fi

# Validate .httptests directory exists
if [[ ! -d "${suite_dir}" ]]; then
  echo "❌ ERROR: .httptests directory not found in ${parent_dir}"
  exit 1
fi

echo "Processing .httptests directory: ${suite_dir}"

test_file="${suite_dir}/test.json"
if [[ ! -f "${test_file}" ]]; then
  echo "❌ ERROR: Missing test.json in ${suite_dir}"
  exit 1
fi

# Generate project name from parent directory
suite_parent="${parent_dir}"
suffix="$(echo "${suite_parent}" | tr '/\\' '_' | tr -cd '[:alnum:]_-' | tr '[:upper:]' '[:lower:]' | sed 's/[_-]*$//' | sed 's/^[_-]*//')"
if [[ -z "${suffix}" || "${suffix}" == "." ]]; then
  project_name="httptests"
else
  project_name="httptests-${suffix}"
fi

echo "Project name: ${project_name}"

gen_script_path="${HTTPTESTS_SCRIPT_DIR}/generate_docker_compose.py"
compose_file="${suite_dir}/docker-compose.yml"

# Generate docker-compose.yml
echo "🔧 Configuring environment..."
if ! python3 "${gen_script_path}" --suite "${suite_dir}" --output "${compose_file}" >/dev/null 2>&1; then
  echo "❌ ERROR: Failed to generate test configuration"
  exit 1
fi

# Start Docker environment
echo "🚀 Starting environment..."
if ! docker compose -f "${compose_file}" -p "${project_name}" up -d --build >/dev/null 2>&1; then
  echo "❌ ERROR: Failed to start test environment"
  exit 1
fi

# Run tests
echo "🧪 Running tests for ${project_name}"
python3 "${HTTPTESTS_SCRIPT_DIR}/main.py" --test-file "${test_file}"
test_exit_code=$?

if [[ ${test_exit_code} -ne 0 ]]; then
  echo ""
  echo "=== Nginx Logs ==="
  docker logs httptests_nginx 2>&1 | grep -Ev "docker-entrypoint\.sh|10-listen-on-ipv6-by-default\.sh" || echo "Could not retrieve nginx logs"
  echo ""
fi

# Cleanup
docker compose -f "${compose_file}" -p "${project_name}" down -v >/dev/null 2>&1 || true

exit ${test_exit_code}
