# docker-tests-example

An example project showing how to create Python tests containers for use with [Selenium](https://www.selenium.dev/) (with Firefox, Chromium and Edge browsers).

## Highlights

* Using [Docker](https://www.docker.com/) for the containers
* Using [Fedora](https://fedoraproject.org/) as the base operating system
* Allows to easily switch between [Firefox](https://www.mozilla.org/en-US/firefox/new/), [Chromium](https://www.chromium.org/chromium-projects/) or [Edge](https://www.microsoft.com/en-us/edge/) using `BROWSER` environment variable (by default Firefox is used)
  * Select arbitrary screen resolution using `SCREEN_RESOLUTION` environment variable (defaults to `DEFAULT_SCREEN_RESOLUTION` which is `1920x1080`)
* Takes full screen screenshots using [Flameshot](https://flameshot.org/) when there are test failures
* Screen is recorded while `pytest` is running using [`ffmpeg`](https://ffmpeg.org/)
* Using [`pytest`](https://docs.pytest.org/)
  * Creates JUnit-style XML report for easy integration with CI/CD tools
* Using [Python Poetry](https://python-poetry.org/) for the dependency management
* Using all the usual & loved Python tooling:
  * [`black`](https://pypi.org/project/black/)
  * [`isort`](https://pypi.org/project/isort/)
  * [`ruff`](https://pypi.org/project/ruff/)
  * [`mypy`](https://pypi.org/project/mypy/)

## Building

```shell
$ docker build -t "docker-tests-example:$(git -c core.abbrev=8 show --no-patch --format='%h')" .
[+] Building 0.1s (16/16) FINISHED                                                   docker:default
 => [internal] load build definition from Dockerfile                                           0.0s
 => => transferring dockerfile: 2.88kB                                                         0.0s
 => [internal] load metadata for docker.io/library/fedora:40                                   0.0s
 => [internal] load .dockerignore                                                              0.0s
 => => transferring context: 97B                                                               0.0s
 => [stage-0  1/11] FROM docker.io/library/fedora:40                                           0.0s
 => [internal] load build context                                                              0.0s
 => => transferring context: 211B                                                              0.0s
 => CACHED [stage-0  2/11] RUN --mount=type=cache,sharing=locked,target=/var/cache/dnf     dn  0.0s
 => CACHED [stage-0  3/11] RUN --mount=type=cache,sharing=locked,target=/root/.cache/pip       0.0s
 => CACHED [stage-0  4/11] RUN curl -sSL "https://github.com/mozilla/geckodriver/releases/dow  0.0s
 => CACHED [stage-0  5/11] RUN curl -sSL "https://msedgewebdriverstorage.blob.core.windows.ne  0.0s
 => CACHED [stage-0  6/11] COPY python+selenium.png /usr/share/wallpapers/                     0.0s
 => CACHED [stage-0  7/11] WORKDIR /srv                                                        0.0s
 => CACHED [stage-0  8/11] RUN mkdir -pv /reports &&     useradd -m -s /bin/bash -g users tes  0.0s
 => CACHED [stage-0  9/11] COPY --chown=testrunner:users pyproject.toml poetry.lock ./         0.0s
 => CACHED [stage-0 10/11] RUN --mount=type=cache,sharing=locked,target=/root/.cache/pypoetry  0.0s
 => CACHED [stage-0 11/11] COPY --chown=testrunner:users bootstrap-tests.sh *.py ./            0.0s
 => exporting to image                                                                         0.0s
 => => exporting layers                                                                        0.0s
 => => writing image sha256:424e718bd9869b803c53c6eb068e0750fce10280b4840bd3d1084b9e91828022   0.0s
 => => naming to docker.io/library/docker-tests-example:c5027386                               0.0s
```

## Usage

Using Firefox:

```shell
$ docker run --rm -it -e BROWSER=firefox -v $(pwd)/reports:/reports "docker-tests-example:$(git -c core.abbrev=8 show --no-patch --format='%h')"
+ TEST_RUN_UUID: 17efcccd-a1f1-4476-970c-7a670533de62
+ cd /srv/
+ trap openbox_ready SIGUSR1
+ openbox_pid=22
+ wait 22
+ openbox --startup 'kill -USR1 20'
++ openbox_ready
++ touch /reports/17efcccd-a1f1-4476-970c-7a670533de62-pytest.started
++ feh --no-fehbg --bg-center /usr/share/wallpapers/python+selenium.png
++ declare -r ffmpeg_pid=28
++ pytest --junitxml=/reports/17efcccd-a1f1-4476-970c-7a670533de62-pytest-junit.xml
++ ffmpeg -loglevel error -f x11grab -i :99 -video_size 1920x1080 -framerate 30 -c:v libx264rgb -crf 0 -preset ultrafast -color_range 2 /reports/17efcccd-a1f1-4476-970c-7a670533de62-video.mkv
======================================= test session starts ========================================
platform linux -- Python 3.12.2, pytest-8.3.3, pluggy-1.5.0 -- /usr/bin/python3.12
cachedir: .pytest_cache
rootdir: /srv
configfile: pyproject.toml
collected 1 item

sample_test.py::test_python_dot_org PASSED                                                   [100%]

-------- generated xml file: /reports/17efcccd-a1f1-4476-970c-7a670533de62-pytest-junit.xml --------
======================================== 1 passed in 6.30s =========================================
++ touch /reports/17efcccd-a1f1-4476-970c-7a670533de62-pytest.ok
++ kill -INT 28
++ wait 28
++ openbox --exit
+ test -f /reports/17efcccd-a1f1-4476-970c-7a670533de62-pytest.ok
```

Using Chromium:

```shell
$ docker run --rm -it -e BROWSER=chromium -v $(pwd)/reports:/reports "docker-tests-example:$(git -c core.abbrev=8 show --no-patch --format='%h')"
+ TEST_RUN_UUID: 201f3133-fb60-47e0-8647-d94e04d4c9c9
+ cd /srv/
+ trap openbox_ready SIGUSR1
+ openbox_pid=22
+ wait 22
+ openbox --startup 'kill -USR1 20'
++ openbox_ready
++ touch /reports/201f3133-fb60-47e0-8647-d94e04d4c9c9-pytest.started
++ feh --no-fehbg --bg-center /usr/share/wallpapers/python+selenium.png
++ declare -r ffmpeg_pid=28
++ pytest --junitxml=/reports/201f3133-fb60-47e0-8647-d94e04d4c9c9-pytest-junit.xml
++ ffmpeg -loglevel error -f x11grab -i :99 -video_size 1920x1080 -framerate 30 -c:v libx264rgb -crf 0 -preset ultrafast -color_range 2 /reports/201f3133-fb60-47e0-8647-d94e04d4c9c9-video.mkv
======================================= test session starts ========================================
platform linux -- Python 3.12.2, pytest-8.3.3, pluggy-1.5.0 -- /usr/bin/python3.12
cachedir: .pytest_cache
rootdir: /srv
configfile: pyproject.toml
collected 1 item

sample_test.py::test_python_dot_org PASSED                                                   [100%]

-------- generated xml file: /reports/201f3133-fb60-47e0-8647-d94e04d4c9c9-pytest-junit.xml --------
======================================== 1 passed in 3.62s =========================================
++ touch /reports/201f3133-fb60-47e0-8647-d94e04d4c9c9-pytest.ok
++ kill -INT 28
++ wait 28
++ openbox --exit
+ test -f /reports/201f3133-fb60-47e0-8647-d94e04d4c9c9-pytest.ok
```

Using Edge:

```shell
$ docker run --rm -it -e BROWSER=edge -v $(pwd)/reports:/reports "docker-tests-example:$(git -c core.abbrev=8 show --no-patch --format='%h')"
+ TEST_RUN_UUID: d30eb22c-9424-40a4-a789-e1903d6eaa79
+ cd /srv/
+ trap openbox_ready SIGUSR1
+ openbox_pid=22
+ wait 22
+ openbox --startup 'kill -USR1 20'
++ openbox_ready
++ touch /reports/d30eb22c-9424-40a4-a789-e1903d6eaa79-pytest.started
++ feh --no-fehbg --bg-center /usr/share/wallpapers/python+selenium.png
++ declare -r ffmpeg_pid=28
++ pytest --junitxml=/reports/d30eb22c-9424-40a4-a789-e1903d6eaa79-pytest-junit.xml
++ ffmpeg -loglevel error -f x11grab -i :99 -video_size 1920x1080 -framerate 30 -c:v libx264rgb -crf 0 -preset ultrafast -color_range 2 /reports/d30eb22c-9424-40a4-a789-e1903d6eaa79-video.mkv
======================================= test session starts ========================================
platform linux -- Python 3.12.2, pytest-8.3.3, pluggy-1.5.0 -- /usr/bin/python3.12
cachedir: .pytest_cache
rootdir: /srv
configfile: pyproject.toml
collected 1 item

sample_test.py::test_python_dot_org PASSED                                                   [100%]

-------- generated xml file: /reports/d30eb22c-9424-40a4-a789-e1903d6eaa79-pytest-junit.xml --------
======================================== 1 passed in 2.77s =========================================
++ touch /reports/d30eb22c-9424-40a4-a789-e1903d6eaa79-pytest.ok
++ kill -INT 28
++ wait 28
++ openbox --exit
+ test -f /reports/d30eb22c-9424-40a4-a789-e1903d6eaa79-pytest.ok
```

**Note**: Make sure that `$(pwd)/reports` is accessible and writable.
