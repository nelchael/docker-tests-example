# docker-tests-example

An example project showing how to create Python tests containers for use with [Selenium](https://www.selenium.dev/) (with Chromium and Firefox browsers).

## Highlights

* Using [Docker](https://www.docker.com/) for the containers
* Using [Fedora](https://fedoraproject.org/) as the base operating system
* Allows to easily switch between [Chromium](https://www.chromium.org/chromium-projects/) and [Firefox](https://www.mozilla.org/en-US/firefox/new/) using `BROWSER` environment variable
  * Select arbitrary screen resolution using `SCREEN_RESOLUTION` environment variable (defaults to `DEFAULT_SCREEN_RESOLUTION` which is `1920x1080`)
* Takes full screen screenshots using [Flameshot](https://flameshot.org/) when there are test failures
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
[+] Building 0.1s (14/14) FINISHED                                                   docker:default
 => [internal] load build definition from Dockerfile                                           0.0s
 => => transferring dockerfile: 1.27kB                                                         0.0s
 => [internal] load metadata for docker.io/library/fedora:39                                   0.0s
 => [internal] load .dockerignore                                                              0.0s
 => => transferring context: 97B                                                               0.0s
 => [internal] load build context                                                              0.0s
 => => transferring context: 165B                                                              0.0s
 => [1/9] FROM docker.io/library/fedora:39                                                     0.0s
 => CACHED [2/9] RUN dnf makecache -q &&     dnf install -y         xorg-x11-server-Xvfb       0.0s
 => CACHED [3/9] RUN pip3 install --no-cache-dir --no-python-version-warning poetry            0.0s
 => CACHED [4/9] RUN curl -sL https://github.com/mozilla/geckodriver/releases/download/v0.34.  0.0s
 => CACHED [5/9] WORKDIR /srv                                                                  0.0s
 => CACHED [6/9] RUN mkdir -pv /reports &&     useradd -m -s /bin/bash -g users testrunner &&  0.0s
 => CACHED [7/9] COPY --chown=testrunner:users pyproject.toml poetry.lock ./                   0.0s
 => CACHED [8/9] RUN poetry check &&     poetry install --only=main                            0.0s
 => CACHED [9/9] COPY --chown=testrunner:users run-tests.sh *.py ./                            0.0s
 => exporting to image                                                                         0.0s
 => => exporting layers                                                                        0.0s
 => => writing image sha256:c09c1800326cc20ea9b750b2b0b53cb56904f447b2df191116fc2abe1d2c3ceb   0.0s
 => => naming to docker.io/library/docker-tests-example:2af46174                               0.0s
```

## Usage

Using Firefox:

```shell
$ docker run --rm -it -e BROWSER=firefox -v $(pwd)/reports:/reports "docker-tests-example:$(git -c core.abbrev=8 show --no-patch --format='%h')"
> TEST_RUN_UUID: de795456-80e0-43d3-a2d8-92306d03bd88
> [19:14:47] cd /srv/
> [19:14:47] trap openbox_ready SIGUSR1
> [19:14:47] openbox_pid=24
> [19:14:47] openbox --startup 'kill -USR1 20'
> [19:14:47] wait 24
>> [19:14:47] openbox_ready
>> [19:14:47] touch /reports/de795456-80e0-43d3-a2d8-92306d03bd88-pytest.started
>> [19:14:47] pytest --junitxml=/reports/de795456-80e0-43d3-a2d8-92306d03bd88-pytest-junit.xml
======================================= test session starts ========================================
platform linux -- Python 3.12.1, pytest-8.0.2, pluggy-1.4.0 -- /usr/bin/python3.12
cachedir: .pytest_cache
rootdir: /srv
configfile: pyproject.toml
collected 1 item

sample_test.py::test_python_dot_org PASSED                                                   [100%]

-------- generated xml file: /reports/de795456-80e0-43d3-a2d8-92306d03bd88-pytest-junit.xml --------
======================================== 1 passed in 5.61s =========================================
>> [19:14:53] touch /reports/de795456-80e0-43d3-a2d8-92306d03bd88-pytest.ok
>> [19:14:53] openbox --exit
> [19:14:53] test -f /reports/de795456-80e0-43d3-a2d8-92306d03bd88-pytest.ok
```

Using Chromium:

```shell
$ docker run --rm -it -e BROWSER=chrome -v $(pwd)/reports:/reports "docker-tests-example:$(git -c core.abbrev=8 show --no-patch --format='%h')"
> TEST_RUN_UUID: 0136df6f-c336-4e0c-8e6b-8232a2b5ea84
> [19:15:03] cd /srv/
> [19:15:03] trap openbox_ready SIGUSR1
> [19:15:03] openbox --startup 'kill -USR1 20'
> [19:15:03] openbox_pid=24
> [19:15:03] wait 24
>> [19:15:03] openbox_ready
>> [19:15:03] touch /reports/0136df6f-c336-4e0c-8e6b-8232a2b5ea84-pytest.started
>> [19:15:03] pytest --junitxml=/reports/0136df6f-c336-4e0c-8e6b-8232a2b5ea84-pytest-junit.xml
======================================= test session starts ========================================
platform linux -- Python 3.12.1, pytest-8.0.2, pluggy-1.4.0 -- /usr/bin/python3.12
cachedir: .pytest_cache
rootdir: /srv
configfile: pyproject.toml
collected 1 item

sample_test.py::test_python_dot_org PASSED                                                   [100%]

-------- generated xml file: /reports/0136df6f-c336-4e0c-8e6b-8232a2b5ea84-pytest-junit.xml --------
======================================== 1 passed in 11.17s ========================================
>> [19:15:15] touch /reports/0136df6f-c336-4e0c-8e6b-8232a2b5ea84-pytest.ok
>> [19:15:15] openbox --exit
> [19:15:15] test -f /reports/0136df6f-c336-4e0c-8e6b-8232a2b5ea84-pytest.ok
```

**Note**: Make sure that `$(pwd)/reports` is accessible and writable.
