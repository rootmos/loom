import sys
import os
import time
import requests

class Client:
    def __init__(self, target=None):
        self.target = target or os.getenv("LOOM_TARGET")
        if self.target is None:
            raise ValueError("client target URL not specified")

    def ping(self):
        rsp = requests.get(f"{self.target}/ping")
        rsp.raise_for_status()
        return rsp.json()

    def stop(self):
        rsp = requests.post(f"{self.target}/stop")
        rsp.raise_for_status()

    def wait_for_service(self):
        def go(f):
            while True:
                try:
                    f()
                    break
                except:
                    print(f"waiting for service at: {self.target}", file=sys.stderr)
                    time.sleep(1)

        go(lambda: self.ping())
