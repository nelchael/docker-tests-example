#!/bin/bash

export REPORTS_DIR="/reports"
export PS4="> [\$(date '+%H:%M:%S')] "
TEST_RUN_UUID="$(uuidgen -r)"
export TEST_RUN_UUID
echo "> TEST_RUN_UUID: ${TEST_RUN_UUID}"

set -x

cd /srv/

function openbox_ready() {
    touch "${REPORTS_DIR}/${TEST_RUN_UUID}-pytest.started"
    pytest --junitxml="${REPORTS_DIR}/${TEST_RUN_UUID}-pytest-junit.xml" && touch "${REPORTS_DIR}/${TEST_RUN_UUID}-pytest.ok"
    openbox --exit
}

trap openbox_ready SIGUSR1

openbox --startup "kill -USR1 ${$}" &
openbox_pid="${!}"

wait "${openbox_pid}"
test -f "${REPORTS_DIR}/${TEST_RUN_UUID}-pytest.ok"
