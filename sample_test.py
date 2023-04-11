#!/usr/bin/env python3

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.wait import WebDriverWait


def test_python_dot_org(selenium_browser):
    selenium_browser.get("http://www.python.org")
    assert "Python" in selenium_browser.title

    elem = selenium_browser.find_element(By.NAME, "q")
    elem.clear()
    elem.send_keys("pycon")
    elem.send_keys(Keys.RETURN)
    WebDriverWait(selenium_browser, 15).until(lambda driver: "<h3>Results</h3>" in driver.page_source)
    assert "<h3>Results</h3>" in selenium_browser.page_source
