import unittest
import time

from . import fresh, b64d
from .client import Client
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
        b = client.mine()
        h1 = client.info()["current"]
        self.assertEqual(b["indep_hash"], h1)
        self.assertNotEqual(h0, h1)

    def test_faucets(self):
        fs = client.faucets()
        self.assertNotEqual(fs, [])
        for f in fs:
            self.assertGreater(client.balance(f), 0)

    def test_balance(self):
        self.assertEqual(client.balance(fresh.address()), 0)

    def test_faucet(self):
        a, q = fresh.address(), fresh.quantity()
        txid = client.faucet(a, q)

        self.assertEqual(client.balance(a), q)
        tx = client.tx(txid)
        self.assertEqual(tx["id"], txid)
        self.assertEqual(tx["target"], a)
        self.assertEqual(int(tx["quantity"]), q)
        self.assertEqual(b64d(tx["data"]), b'')
