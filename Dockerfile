FROM fedora:38

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3041
RUN dnf makecache -q && \
    dnf install -y \
        xorg-x11-server-Xvfb \
        openbox \
        firefox \
        chromium chromedriver \
        python3-pip \
	&& \
    dnf clean all

# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir --no-python-version-warning poetry

RUN curl -sL https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz | tar zxf - -C /tmp/ && \
    install --mode=755 /tmp/geckodriver /usr/local/bin/ && \
    rm -rf /tmp/geckodriver

WORKDIR /srv
VOLUME [ "/reports" ]
RUN mkdir -pv /reports && \
    useradd -m -s /bin/bash -g users testrunner && \
    chown -Rv testrunner:users . /reports
USER testrunner
ENV PATH=/home/testrunner/.local/bin:${PATH}

COPY --chown=testrunner:users pyproject.toml poetry.lock ./

RUN poetry --no-cache export -f requirements.txt --only=main --output requirements.txt && \
    pip3 install --user --no-cache-dir --no-python-version-warning -r requirements.txt
COPY --chown=testrunner:users run-tests.sh *.py ./

CMD ["/usr/bin/xvfb-run", "-a", "-s", "-screen 0 1024x768x24 -ac +extension RANDR", "/bin/bash", "/srv/run-tests.sh"]
