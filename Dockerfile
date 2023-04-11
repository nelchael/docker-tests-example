FROM fedora:41

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3040,DL3041
RUN --mount=type=cache,sharing=locked,target=/var/cache/libdnf5 \
    dnf install -y --nodocs --setopt keepcache=True \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" \
    && \
    rpm --import "https://packages.microsoft.com/keys/microsoft.asc" && \
    curl -sSL "https://packages.microsoft.com/yumrepos/edge/config.repo" -o "/etc/yum.repos.d/microsoft-edge.repo" && \
    dnf install -y --nodocs --setopt keepcache=True \
        chromedriver \
        chromium \
        feh \
        ffmpeg \
        firefox \
        flameshot \
        microsoft-edge-stable \
        openbox \
        python3-pip \
        unzip \
        xorg-x11-server-Xvfb \
        yq \
    && \
    dnf list --installed > /dockerenv-dnf-bom && \
    rm -f /var/log/dnf5.log*

# hadolint ignore=DL3013,DL3042
RUN --mount=type=cache,sharing=locked,target=/root/.cache \
    pip3 install --no-python-version-warning poetry

ARG GECKODRIVER_VERSION=0.36.0
RUN curl -sSL "https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz" | tar zxf - -C /tmp/ && \
    install --mode=755 /tmp/geckodriver /usr/local/bin/ && \
    rm -rf /tmp/geckodriver

RUN curl -sSL "https://msedgewebdriverstorage.blob.core.windows.net/edgewebdriver/?restype=container&comp=list&prefix=$(rpm --query --queryformat='%{VERSION}' microsoft-edge-stable | cut -d. -f 1-3)" | \
        yq --input-format xml '.EnumerationResults.Blobs.Blob[].Url' | \
        grep _linux64 \
        | sort --version-sort \
        | tail -n 1 \
        | tee /tmp/edgedriver_linux64.url && \
    curl -sSL "$(< /tmp/edgedriver_linux64.url)" -o /tmp/edgedriver_linux64.zip && \
    unzip /tmp/edgedriver_linux64.zip msedgedriver -d /usr/local/bin/ && \
    chmod 755 /usr/local/bin/msedgedriver && \
    rm -rf /tmp/edgedriver_linux64.url /tmp/edgedriver_linux64.zip

COPY python+selenium.png /usr/share/wallpapers/

WORKDIR /srv
VOLUME ["/reports"]
RUN mkdir -pv /reports && \
    useradd -m -s /bin/bash -g users testrunner && \
    chown -Rv testrunner:users . /reports

COPY --chown=testrunner:users pyproject.toml poetry.lock ./
ENV POETRY_VIRTUALENVS_CREATE="false"
RUN --mount=type=cache,sharing=locked,target=/root/.cache \
    poetry check && \
    poetry install --only=main
COPY --chown=testrunner:users bootstrap-tests.sh *.py ./

USER testrunner
ARG DEFAULT_SCREEN_RESOLUTION="1920x1080"
ENV SCREEN_RESOLUTION="${DEFAULT_SCREEN_RESOLUTION}"

CMD ["/bin/bash", "-c", "/usr/bin/xvfb-run -a -s \"-screen 0 ${SCREEN_RESOLUTION}x24 -ac +extension RANDR\" /bin/bash /srv/bootstrap-tests.sh"]
