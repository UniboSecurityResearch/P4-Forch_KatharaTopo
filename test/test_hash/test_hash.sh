#!/bin/bash

set -e

start=$(date +%s%N)
./crc32.py "$(perl -e 'print "A"x256')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "CRC32 256 = $time" > ./hash_time.txt

start=$(date +%s%N)
./crc32.py "$(perl -e 'print "A"x512')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "CRC32 512 = $time" >> ./hash_time.txt

start=$(date +%s%N)
./crc32.py "$(perl -e 'print "A"x1024')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "CRC32 1024 = $time" >> ./hash_time.txt



start=$(date +%s%N)
./xxh.py "$(perl -e 'print "A"x256')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "XXH64 256 = $time" >> ./hash_time.txt

start=$(date +%s%N)
./xxh.py "$(perl -e 'print "A"x512')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "XXH64 512 = $time" >> ./hash_time.txt

start=$(date +%s%N)
./xxh.py "$(perl -e 'print "A"x1024')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "XXH64 1024 = $time" >> ./hash_time.txt



start=$(date +%s%N)
./md5.py "$(perl -e 'print "A"x256')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "MD5 256 = $time" >> ./hash_time.txt

start=$(date +%s%N)
./md5.py "$(perl -e 'print "A"x512')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "MD5 512 = $time" >> ./hash_time.txt

start=$(date +%s%N)
./md5.py "$(perl -e 'print "A"x1024')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "MD5 1024 = $time" >> ./hash_time.txt



start=$(date +%s%N)
./sha256.py "$(perl -e 'print "A"x256')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "SHA256 256 = $time" >> ./hash_time.txt

start=$(date +%s%N)
./sha256.py "$(perl -e 'print "A"x512')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "SHA256 512 = $time" >> ./hash_time.txt

start=$(date +%s%N)
./sha256.py "$(perl -e 'print "A"x1024')"
end=$(date +%s%N)
time=$(expr $end - $start)
echo "SHA256 1024 = $time" >> ./hash_time.txt
