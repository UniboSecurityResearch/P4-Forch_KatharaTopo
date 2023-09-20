#!/usr/bin/python3

import hashlib, sys

hashlib.sha256(sys.argv[1].encode()).hexdigest()
