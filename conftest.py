#!/usr/bin/env python3

import os
import pathlib
import subprocess
import time
import warnings
from typing import Generator

import pytest
import slugify
from selenium import webdriver
from selenium.common.exceptions import WebDriverException


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item: pytest.Function, call: pytest.CallInfo):  # noqa: ARG001
    test_report: pytest.TestReport = (yield).get_result()
    if test_report.when != "call" or not test_report.failed:
        return

    path = pathlib.Path(slugify.slugify(f"{os.getenv('TEST_RUN_UUID', '')}-{test_report.nodeid}") + ".png")
    if reports_dir := os.getenv("REPORTS_DIR"):
        path = pathlib.Path(reports_dir) / path
    try:
        subprocess.check_call(["flameshot", "full", "-p", path], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    except Exception as exception:
        warnings.warn(f"Failed to invoke flameshot: {exception}", RuntimeWarning)


def _create_firefox_driver() -> webdriver.Firefox:
    options = webdriver.FirefoxOptions()

    # No Firefox specific options to set...

    return webdriver.Firefox(options=options)


def _create_chrome_driver() -> webdriver.Chrome:
    options = webdriver.ChromeOptions()

    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    return webdriver.Chrome(options=options)


def _create_edge_driver() -> webdriver.Edge:
    options = webdriver.EdgeOptions()

    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    return webdriver.Edge(options=options)


@pytest.fixture(scope="session")
def selenium_browser() -> Generator[webdriver.Remote, None, None]:
    driver_selection = os.getenv("BROWSER", "firefox")
    match driver_selection:
        case "firefox":
            driver: webdriver.Remote = _create_firefox_driver()
        case "chromium" | "chrome":
            driver = _create_chrome_driver()
        case "edge":
            driver = _create_edge_driver()
        case _:
            raise ValueError(f"Unsupported browser: {driver_selection}")

    driver.maximize_window()

    yield driver

    time.sleep(0.5)
    try:
        driver.quit()
    except WebDriverException:
        pass  # Ignore
