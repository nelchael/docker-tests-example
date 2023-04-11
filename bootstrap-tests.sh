#!/bin/bash

export REPORTS_DIR="/reports"
export PS4="+ "
TEST_RUN_UUID="$(uuidgen -r)"
export TEST_RUN_UUID
echo "${PS4}TEST_RUN_UUID: ${TEST_RUN_UUID}"

set -x

cd /srv/

function openbox_ready() {
    touch "${REPORTS_DIR}/${TEST_RUN_UUID}-pytest.started"
    feh --no-fehbg --bg-center "/usr/share/wallpapers/python+selenium.png"

    ffmpeg -loglevel error \
        -f x11grab -i "${DISPLAY}" -video_size "${SCREEN_RESOLUTION}" -framerate 30 \
        -c:v libx264rgb -crf 0 -preset ultrafast -color_range 2 "${REPORTS_DIR}/${TEST_RUN_UUID}-video.mkv" &
    declare -r ffmpeg_pid="${!}"

    pytest --junitxml="${REPORTS_DIR}/${TEST_RUN_UUID}-pytest-junit.xml" && touch "${REPORTS_DIR}/${TEST_RUN_UUID}-pytest.ok"

    kill -INT "${ffmpeg_pid}"
    wait "${ffmpeg_pid}"

    openbox --exit
}

trap openbox_ready SIGUSR1

openbox --startup "kill -USR1 ${$}" &
openbox_pid="${!}"

wait "${openbox_pid}"
test -f "${REPORTS_DIR}/${TEST_RUN_UUID}-pytest.ok"
