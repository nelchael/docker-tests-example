#!/bin/bash

export PS4="> [\$(date '+%H:%M:%S')] "

set -x

cd /srv/

function openbox_ready() {
    pytest --junitxml=/reports/pytest-junit.xml

    openbox --exit
}

trap openbox_ready SIGUSR1

openbox --startup "kill -USR1 ${$}" &
openbox_pid="${!}"

wait "${openbox_pid}"
