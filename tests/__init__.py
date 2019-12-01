import base64

def restore_b64_padding(s):
    return s + ('=' * (-len(s) % 4))

def b64e(bs):
    return str(base64.urlsafe_b64encode(bs), "UTF-8").rstrip("=")

def b64d(s):
    return base64.urlsafe_b64decode(restore_b64_padding(s))
