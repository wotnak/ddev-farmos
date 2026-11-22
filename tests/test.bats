#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail
  unset TESTDIR

  # Override this variable for your add-on:
  export GITHUB_REPO=wotnak/ddev-farmos

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  mkdir -p "${HOME}/tmp"
  TESTDIR="$(mktemp -d "${HOME}/tmp/test-$(basename "${GITHUB_REPO}")-XXXXXXXXXX")"
  PROJNAME="$(printf '%s' "${TESTDIR##*/}" | LC_ALL=C tr '[:upper:]' '[:lower:]')"
  export TESTDIR PROJNAME
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  export CI=true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site --project-type=php
  assert_success
}

health_checks() {
  # Install farmOS v4
  run ddev composer create-project farmos/project:4.x-dev --no-interaction --no-install
  assert_success
  allowedPlugins=(
    "composer/installers"
    "cweagans/composer-patches"
    "dealerdirect/phpcodesniffer-composer-installer"
    "drupal/core-composer-scaffold"
    "oomphinc/composer-installers-extender"
    "phpstan/extension-installer"
    "wikimedia/composer-merge-plugin"
  )
  for plugin in "${allowedPlugins[@]}"; do
    run ddev composer config --no-plugins "allow-plugins.$plugin" true
    assert_success
  done
  run ddev composer install --no-interaction
  assert_success
  run ddev drush site:install farm --account-name=admin --account-pass=admin -y
  assert_success

  # Verify the installed profile.
  run ddev drush php:eval 'echo \Drupal::config("core.extension")->get("profile");'
  assert_success
  assert_output 'farm'

  check_dashboard_access
}

check_dashboard_access() {
  local site_url="https://${PROJNAME}.ddev.site"
  local cookie_jar="${BATS_TEST_TMPDIR}/cookies"

  run curl --fail --silent --show-error --cookie-jar "$cookie_jar" \
    --output .ddev/test-login.html "$site_url/user/login"
  assert_success

  run ddev exec --raw -- php -r '
    $document = \Dom\HTMLDocument::createFromFile($argv[1]);
    $fields = [];
    foreach ($document->querySelectorAll("form#user-login-form input[type=hidden][name]") as $input) {
      $fields[$input->getAttribute("name")] = $input->getAttribute("value");
    }
    if (($fields["form_id"] ?? null) !== "user_login_form" || empty($fields["form_build_id"])) {
      fwrite(STDERR, "The login form is missing its hidden fields.\n");
      exit(1);
    }
    echo http_build_query($fields);
  ' /mnt/ddev_config/test-login.html
  assert_success
  local login_fields="$output"

  run curl --fail --silent --show-error --cookie "$cookie_jar" --cookie-jar "$cookie_jar" \
    --data "$login_fields" --data-urlencode 'name=admin' --data-urlencode 'pass=admin' \
    --data-urlencode 'op=Log in' "$site_url/user/login"
  assert_success

  run curl --fail --silent --show-error --cookie "$cookie_jar" "$site_url/dashboard"
  assert_success
  assert_output --partial 'Welcome to farmOS'
}

teardown() {
  set -eu -o pipefail
  if [ -z "${TESTDIR:-}" ]; then
    return 0
  fi
  if [ -f "${TESTDIR}/.ddev/config.yaml" ]; then
    ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  fi
  # Keep the test directories in GitHub Actions and export their shared prefix for artifact globs.
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV}" ] && printf 'TESTDIR=%s\n' "${TESTDIR%-*}" >> "${GITHUB_ENV}"
  else
    rm -rf -- "${TESTDIR}"
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
