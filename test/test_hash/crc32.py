#!/usr/bin/python3

import zlib, sys

hex(zlib.crc32(sys.argv[1].encode()) & 0xffffffff)
