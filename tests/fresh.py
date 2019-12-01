import random
from . import b64e

def bs(n):
    return bytes(random.getrandbits(8) for _ in range(n))

def address():
    return b64e(bs(32))

def quantity(lower=1000000000, upper=1000000000000):
    return random.randint(lower, upper)
