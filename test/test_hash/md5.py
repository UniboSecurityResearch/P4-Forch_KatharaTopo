#!/usr/bin/python3

import hashlib, sys

hashlib.md5(sys.argv[1].encode()).hexdigest()
