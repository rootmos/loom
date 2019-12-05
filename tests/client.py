import sys
import os
import time
import requests

class Client:
    def __init__(self, target=None):
        self.target = target or os.getenv("LOOM_TARGET")
        if self.target is None:
            raise ValueError("client target URL not specified")
        self.loom_base_url = f"{self.target}/loom"
        self.arweave_base_url = f"{self.target}/arweave"

    def ping(self):
        rsp = requests.get(f"{self.loom_base_url}/ping")
        rsp.raise_for_status()
        return rsp.json()

    def info(self):
        rsp = requests.get(f"{self.arweave_base_url}/info")
        rsp.raise_for_status()
        return rsp.json()

    def block(self, indep_hash):
        rsp = requests.get(f"{self.arweave_base_url}/block/hash/{indep_hash}")
        rsp.raise_for_status()
        return rsp.json()

    def tx(self, txid):
        rsp = requests.get(f"{self.arweave_base_url}/tx/{txid}")
        rsp.raise_for_status()
        return rsp.json()

    def submit(self, tx):
        rsp = requests.post(f"{self.arweave_base_url}/tx", json=tx)
        rsp.raise_for_status()

    def balance(self, address):
        rsp = requests.get(f"{self.arweave_base_url}/wallet/{address}/balance")
        rsp.raise_for_status()
        return rsp.json()

    def last_tx(self, address):
        rsp = requests.get(f"{self.arweave_base_url}/wallet/{address}/last_tx")
        rsp.raise_for_status()
        return str(rsp.content, "UTF-8")

    def reward(self, target=None, data=None):
        size = len(data) if data is not None else 0
        if target is not None:
            rsp = requests.get(f"{self.arweave_base_url}/price/{size}/{target}")
        else:
            rsp = requests.get(f"{self.arweave_base_url}/price/{size}")
        rsp.raise_for_status()
        return rsp.json()

    def mine(self):
        rsp = requests.post(f"{self.loom_base_url}/mine")
        rsp.raise_for_status()
        return rsp.json()

    def faucets(self):
        rsp = requests.get(f"{self.loom_base_url}/faucet")
        rsp.raise_for_status()
        return rsp.json()

    def faucet(self, beneficiary, quantity):
        body = { "beneficiary": beneficiary, "quantity": quantity }
        rsp = requests.post(f"{self.loom_base_url}/faucet", json=body)
        rsp.raise_for_status()
        return rsp.json()["tx_id"]

    def wait(self, tx_id):
        rsp = requests.get(f"{self.loom_base_url}/wait/{tx_id}")
        rsp.raise_for_status()
        return rsp.json()

    def stop(self):
        rsp = requests.post(f"{self.loom_base_url}/stop")
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
        go(lambda: self.info())
