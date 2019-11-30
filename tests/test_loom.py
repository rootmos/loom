import unittest
import time

from client import Client
client = Client()

class LoomTests(unittest.TestCase):
    def test_ping(self):
        self.assertEqual(client.ping(), "pong")

    def test_info(self):
        i = client.info()
        self.assertEqual(i["network"], "arweave.N.1")

    def test_block(self):
        h = client.info()["current"]
        b = client.block(h)
        self.assertEqual(h, b["indep_hash"])

    def test_mine(self):
        h0 = client.info()["current"]
        client.mine()
        time.sleep(1.0)
        h1 = client.info()["current"]
        self.assertNotEqual(h0, h1)

    def test_faucet(self):
        fs = client.faucets()
        self.assertNotEqual(fs, [])
        for f in fs:
            self.assertGreater(client.balance(f), 0)
