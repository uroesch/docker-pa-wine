#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
export DISPLAY=:7777
export WINEDLLOVERRIDES="mscoree,mshtml="

# -----------------------------------------------------------------------------
# Globals
# -----------------------------------------------------------------------------
# Set user account and run values
USER_NAME=${USER_NAME:-wineuser}
USER_UID=${USER_UID:-1010}
USER_GID=${USER_GID:-"${USER_UID}"}
USER_HOME=${USER_HOME:-/home/"${USER_NAME}"}
USER_PASSWD=${USER_PASSWD:-"$(openssl passwd -1 -salt "$(openssl rand -base64 6)" "${USER_NAME}")"}
RUN_AS_ROOT=${RUN_AS_ROOT:-no}
FORCED_OWNERSHIP=${FORCED_OWNERSHIP:-no}
TZ=${TZ:-UTC}

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
function is_enabled() {
  [[ ${1} =~ ^(yes|on|true|1)$ ]]
}

function is_disabled() {
  [[ ${1} =~ ^(no|off|false|0)$ ]]
}

function create_user() {
  # Create the user account
  ! grep -q ":${USER_GID}:$" /etc/group && \
    groupadd --gid "${USER_GID}" "${USER_NAME}"
  useradd \
    --shell /bin/bash \
    --uid "${USER_UID}" \
    --gid "${USER_GID}" \
    --password "${USER_PASSWD}" \
    --no-create-home \
    --home-dir "${USER_HOME}" \
    "${USER_NAME}"
}

function create_homedir() {
  # Create the user's home if it doesn't exist
  [ ! -d "${USER_HOME}" ] && mkdir -p "${USER_HOME}"

  # Take ownership of user's home directory if owned by root or 
  # if FORCED_OWNERSHIP is enabled
  OWNER_IDS="$(stat -c "%u:%g" "${USER_HOME}")"
  if [[ ${OWNER_IDS} != ${USER_UID}:${USER_GID} ]]; then
    if [[ ${OWNER_IDS} == 0:0 ]] || is_enabled "${FORCED_OWNERSHIP}"; then
      chown -R "${USER_UID}":"${USER_GID}" "${USER_HOME}"
    else
      printf "ERROR: User's home '%s' is currently owned by %s\n" \
        "${USER_HOME}" \
        "$(stat -c "%U:%G" "${USER_HOME}")"
      printf "Use option --force-owner to enable user '%s' to take ownership" \
        "${USER_NAME}"
      exit 1
    fi
  fi
}

function configure_timezone() {
  ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime && \
    echo "${TZ}" > /etc/timezone
}

function start_x() { 
  nohup /usr/bin/Xvfb ${DISPLAY} >/dev/null 2>&1 &
}

function run_command() {
  # Run in X11 redirection mode as $USER_NAME (default)
  if is_disabled "${RUN_AS_ROOT}"; then
    # Run in X11 redirection mode as user
    exec gosu "${USER_NAME}" "${@}"
    # Run in X11 redirection mode as root
  elif is_enabled "${RUN_AS_ROOT}"; then
    exec "${@}"
  fi
}

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
create_user
create_homedir
configure_timezone
start_x
run_command "${@}"
