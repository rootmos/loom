from . import b64d, b64e

from Crypto.Hash import SHA256
from Crypto.PublicKey import RSA

def owner_to_pubkey(o):
    return RSA.construct((int.from_bytes(b64d(o), "big"), 65537))

def pubkey_to_owner(pk):
    return pk.n.to_bytes((pk.n.bit_length() + 7) // 8, byteorder="big")

def pubkey_to_address(pk):
    return b64e(SHA256.new(pubkey_to_owner(pk)).digest())

def new():
    key = RSA.generate(bits=4096)
    a = pubkey_to_address(key.publickey())
    return a, key
