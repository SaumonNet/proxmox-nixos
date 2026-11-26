from urllib.parse import quote

from playwright.sync_api import sync_playwright


def open_host_console(context):
    origin = "https://mypve:8006"
    login = context.request.post(
        f"{origin}/api2/json/access/ticket",
        form={"username": "root@pam", "password": "console-test"},
        fail_on_status_code=True,
    )
    ticket = login.json()["data"]["ticket"]
    context.add_cookies([{
        "name": "PVEAuthCookie",
        "value": quote(ticket, safe=""),
        "url": origin,
    }])

    page = context.new_page()
    page.goto(f"{origin}/?console=shell&novnc=1&node=mypve")
    return page


with sync_playwright() as playwright:
    browser = playwright.chromium.launch(channel="chromium")
    # The disposable node generates its own CA at boot.
    context = browser.new_context(ignore_https_errors=True)
    page = open_host_console(context)
    canvas = page.locator("html.noVNC_connected #noVNC_container canvas")
    canvas.focus()
    page.keyboard.type("exec touch /tmp/novnc-ok")
    page.keyboard.press("Enter")

    # exec ends the console shell after creating the marker. Wait for noVNC
    # to see the disconnect before closing the browser.
    canvas.wait_for(state="detached")
    browser.close()
