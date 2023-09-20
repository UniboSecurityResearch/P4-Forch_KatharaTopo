#!/usr/bin/python3

import xxhash, sys

xxhash.xxh64(sys.argv[1]).hexdigest()
