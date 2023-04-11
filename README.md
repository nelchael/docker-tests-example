# docker-tests-example

An example project showing how to create Python tests containers for use with [Selenium](https://www.selenium.dev/) (with Chromium and Firefox browsers).

## Highlights

* Using [Docker](https://www.docker.com/) for the containers
* Allowing easily to switch between [Chromium](https://www.chromium.org/chromium-projects/) and [Firefox](https://www.mozilla.org/en-US/firefox/new/) using `BROWSER` environment variable
* Using [`pytest`](https://docs.pytest.org/)
  * Creates JUnit-style XML report for easy integration with CI/CD tools
* Using [Python Poetry](https://python-poetry.org/) for the dependency management
* Using all the usual & loved Python tooling:
  * [`black`](https://pypi.org/project/black/)
  * [`isort`](https://pypi.org/project/isort/)
  * [`ruff`](https://pypi.org/project/ruff/)
  * [`mypy`](https://pypi.org/project/mypy/)
