from . import b64d, b64e, wallet

from Crypto.Hash import SHA256
from Crypto.PublicKey import RSA
from Crypto.Signature import pss as PSS

def signing_data(tx):
    return (
        b64d(tx["owner"]) +
        b64d(tx["target"]) +
        b64d(tx["data"]) +
        tx["quantity"].encode("UTF-8") +
        tx["reward"].encode("UTF-8") +
        b64d(tx["last_tx"])
    )

def sign(tx, key):
    tx["owner"] = b64e(wallet.pubkey_to_owner(key.publickey()))
    sig = PSS.new(key, salt_bytes=20).sign(SHA256.new(signing_data(tx)))
    tx["signature"] = b64e(sig)
    tx["id"] = b64e(SHA256.new(sig).digest())
    return tx

def verify(tx):
    pk = owner_to_pubkey(tx["owner"])
    PSS.new(pk, salt_bytes=20).verify(
        msg_hash = SHA256.new(signing_data(tx)),
        signature = b64d(tx["signature"])
    )

def new(last_tx, target=None, quantity=None, reward=None, data=None):
    if quantity is None: quantity = 0
    if data is None: data = b''

    tx = {
        "last_tx": last_tx,
        "target": target if target is not None else "",
        "data": b64e(data),
        "quantity": str(quantity),
    }

    if reward: tx["reward"] = str(reward)

    return tx
