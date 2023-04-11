# docker-tests-example

An example project showing how to create Python tests containers for use with [Selenium](https://www.selenium.dev/) (with Chromium and Firefox browsers).

## Highlights

* Using [Docker](https://www.docker.com/) for the containers
* Using [Fedora](https://fedoraproject.org/) as the base operating system
* Allows to easily switch between [Chromium](https://www.chromium.org/chromium-projects/) and [Firefox](https://www.mozilla.org/en-US/firefox/new/) using `BROWSER` environment variable
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
[+] Building 0.1s (15/15) FINISHED                                                   docker:default
 => [internal] load build definition from Dockerfile                                           0.0s
 => => transferring dockerfile: 1.59kB                                                         0.0s
 => [internal] load metadata for docker.io/library/fedora:40                                   0.0s
 => [internal] load .dockerignore                                                              0.0s
 => => transferring context: 97B                                                               0.0s
 => [ 1/10] FROM docker.io/library/fedora:40                                                   0.0s
 => [internal] load build context                                                              0.0s
 => => transferring context: 211B                                                              0.0s
 => CACHED [ 2/10] RUN dnf install -y         "https://mirrors.rpmfusion.org/free/fedora/rpmf  0.0s
 => CACHED [ 3/10] RUN pip3 install --no-cache-dir --no-python-version-warning poetry          0.0s
 => CACHED [ 4/10] RUN curl -sL https://github.com/mozilla/geckodriver/releases/download/v0.3  0.0s
 => CACHED [ 5/10] COPY python+selenium.png /                                                  0.0s
 => CACHED [ 6/10] WORKDIR /srv                                                                0.0s
 => CACHED [ 7/10] RUN mkdir -pv /reports &&     useradd -m -s /bin/bash -g users testrunner   0.0s
 => CACHED [ 8/10] COPY --chown=testrunner:users pyproject.toml poetry.lock ./                 0.0s
 => CACHED [ 9/10] RUN poetry check &&     poetry install --only=main                          0.0s
 => CACHED [10/10] COPY --chown=testrunner:users bootstrap-tests.sh *.py ./                    0.0s
 => exporting to image                                                                         0.0s
 => => exporting layers                                                                        0.0s
 => => writing image sha256:6e51ea8b5dd5569b272cc56f6ee0d3bd688e8bb3b4d80b70982c73def1194275   0.0s
 => => naming to docker.io/library/docker-tests-example:8598b76e                               0.0s
```

## Usage

Using Firefox:

```shell
$ docker run --rm -it -e BROWSER=firefox -v $(pwd)/reports:/reports "docker-tests-example:$(git -c core.abbrev=8 show --no-patch --format='%h')"
> TEST_RUN_UUID: b5a4f04e-6e1e-4354-8b8a-0a3fa963c40f
> [10:27:00] cd /srv/
> [10:27:00] trap openbox_ready SIGUSR1
> [10:27:00] openbox_pid=24
> [10:27:00] openbox --startup 'kill -USR1 20'
> [10:27:00] wait 24
>> [10:27:00] openbox_ready
>> [10:27:00] touch /reports/b5a4f04e-6e1e-4354-8b8a-0a3fa963c40f-pytest.started
>> [10:27:00] feh --no-fehbg --bg-center /python+selenium.png
>> [10:27:00] declare -r ffmpeg_pid=39
>> [10:27:00] ffmpeg -loglevel error -f x11grab -i :99 -video_size 1920x1080 -framerate 10 -c:v libx264rgb -crf 0 -preset ultrafast -color_range 2 /reports/b5a4f04e-6e1e-4354-8b8a-0a3fa963c40f-video.mkv
>> [10:27:00] pytest --junitxml=/reports/b5a4f04e-6e1e-4354-8b8a-0a3fa963c40f-pytest-junit.xml
======================================= test session starts ========================================
platform linux -- Python 3.12.2, pytest-8.2.0, pluggy-1.5.0 -- /usr/bin/python3.12
cachedir: .pytest_cache
rootdir: /srv
configfile: pyproject.toml
collected 1 item

sample_test.py::test_python_dot_org PASSED                                                   [100%]

-------- generated xml file: /reports/b5a4f04e-6e1e-4354-8b8a-0a3fa963c40f-pytest-junit.xml --------
======================================== 1 passed in 5.42s =========================================
>> [10:27:06] touch /reports/b5a4f04e-6e1e-4354-8b8a-0a3fa963c40f-pytest.ok
>> [10:27:06] kill -INT 39
>> [10:27:06] wait 39
>> [10:27:06] openbox --exit
> [10:27:06] test -f /reports/b5a4f04e-6e1e-4354-8b8a-0a3fa963c40f-pytest.ok
```

Using Chromium:

```shell
$ docker run --rm -it -e BROWSER=chromium -v $(pwd)/reports:/reports "docker-tests-example:$(git -c core.abbrev=8 show --no-patch --format='%h')"
> TEST_RUN_UUID: c22d4590-bfa6-42eb-86b9-fa38e32bc311
> [10:27:53] cd /srv/
> [10:27:53] trap openbox_ready SIGUSR1
> [10:27:53] openbox_pid=24
> [10:27:53] openbox --startup 'kill -USR1 20'
> [10:27:53] wait 24
>> [10:27:53] openbox_ready
>> [10:27:53] touch /reports/c22d4590-bfa6-42eb-86b9-fa38e32bc311-pytest.started
>> [10:27:53] feh --no-fehbg --bg-center /python+selenium.png
>> [10:27:53] declare -r ffmpeg_pid=39
>> [10:27:53] ffmpeg -loglevel error -f x11grab -i :99 -video_size 1920x1080 -framerate 10 -c:v libx264rgb -crf 0 -preset ultrafast -color_range 2 /reports/c22d4590-bfa6-42eb-86b9-fa38e32bc311-video.mkv
>> [10:27:53] pytest --junitxml=/reports/c22d4590-bfa6-42eb-86b9-fa38e32bc311-pytest-junit.xml
======================================= test session starts ========================================
platform linux -- Python 3.12.2, pytest-8.2.0, pluggy-1.5.0 -- /usr/bin/python3.12
cachedir: .pytest_cache
rootdir: /srv
configfile: pyproject.toml
collected 1 item

sample_test.py::test_python_dot_org PASSED                                                   [100%]

-------- generated xml file: /reports/c22d4590-bfa6-42eb-86b9-fa38e32bc311-pytest-junit.xml --------
======================================== 1 passed in 11.76s ========================================
>> [10:28:05] touch /reports/c22d4590-bfa6-42eb-86b9-fa38e32bc311-pytest.ok
>> [10:28:05] kill -INT 39
>> [10:28:05] wait 39
>> [10:28:05] openbox --exit
> [10:28:05] test -f /reports/c22d4590-bfa6-42eb-86b9-fa38e32bc311-pytest.ok
```

**Note**: Make sure that `$(pwd)/reports` is accessible and writable.
