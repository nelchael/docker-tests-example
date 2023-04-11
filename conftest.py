#!/usr/bin/env python3

import os
from typing import Generator

import pytest
from selenium import webdriver
from selenium.common.exceptions import WebDriverException


def _create_chrome_driver() -> webdriver.Chrome:
    options = webdriver.ChromeOptions()

    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    return webdriver.Chrome(options=options)


def _create_firefox_driver() -> webdriver.Firefox:
    options = webdriver.FirefoxOptions()

    # No Firefox specific options to set...

    return webdriver.Firefox(options=options)


@pytest.fixture(scope="session")
def selenium_browser() -> Generator[webdriver.Remote, None, None]:
    driver_selection = os.getenv("BROWSER", "chrome")
    match driver_selection:
        case "chrome":
            driver: webdriver.Remote = _create_chrome_driver()
        case "firefox":
            driver = _create_firefox_driver()
        case _:
            raise ValueError(f"Unsupported browser: {driver_selection}")

    driver.maximize_window()

    yield driver

    try:
        driver.quit()
    except WebDriverException:
        pass  # Ignore
