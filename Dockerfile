FROM fedora:39

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3041
RUN dnf makecache -q && \
    dnf install -y \
        xorg-x11-server-Xvfb \
        openbox \
        flameshot \
        firefox \
        chromium chromedriver \
        python3-pip \
	&& \
    dnf clean all

# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir --no-python-version-warning poetry

RUN curl -sL https://github.com/mozilla/geckodriver/releases/download/v0.34.0/geckodriver-v0.34.0-linux64.tar.gz | tar zxf - -C /tmp/ && \
    install --mode=755 /tmp/geckodriver /usr/local/bin/ && \
    rm -rf /tmp/geckodriver

WORKDIR /srv
VOLUME ["/reports"]
RUN mkdir -pv /reports && \
    useradd -m -s /bin/bash -g users testrunner && \
    chown -Rv testrunner:users . /reports

COPY --chown=testrunner:users pyproject.toml poetry.lock ./
ENV POETRY_VIRTUALENVS_CREATE="false"
RUN poetry check && \
    poetry install --only=main
COPY --chown=testrunner:users run-tests.sh *.py ./

USER testrunner
ARG DEFAULT_SCREEN_RESOLUTION="1920x1080"
ENV SCREEN_RESOLUTION="${DEFAULT_SCREEN_RESOLUTION}"

CMD ["/bin/bash", "-c", "/usr/bin/xvfb-run -a -s \"-screen 0 ${SCREEN_RESOLUTION}x24 -ac +extension RANDR\" /bin/bash /srv/run-tests.sh"]
