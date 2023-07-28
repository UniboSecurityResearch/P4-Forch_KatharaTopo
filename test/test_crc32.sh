#!/bin/bash

./test_network.sh -d 256 -i 1 --crc32
./test_network.sh -d 512 -i 1 --crc32
./test_network.sh -d 1024 -i 1 --crc32

./test_network.sh -d 256 -i 10 --crc32
./test_network.sh -d 512 -i 10 --crc32
./test_network.sh -d 1024 -i 10 --crc32

./test_network.sh -d 256 -i 100 --crc32
./test_network.sh -d 512 -i 100 --crc32
./test_network.sh -d 1024 -i 100 --crc32

./test_network.sh -d 256 -i 1000 --crc32
./test_network.sh -d 512 -i 1000 --crc32
./test_network.sh -d 1024 -i 1000 --crc32

./test_network.sh -d 256 -i 5000 --crc32
./test_network.sh -d 512 -i 5000 --crc32
./test_network.sh -d 1024 -i 5000 --crc32

./test_network.sh -d 256 -i 7500 --crc32
./test_network.sh -d 512 -i 7500 --crc32
./test_network.sh -d 1024 -i 7500 --crc32

./test_network.sh -d 256 -i 10000 --crc32
./test_network.sh -d 512 -i 10000 --crc32
./test_network.sh -d 1024 -i 10000 --crc32

./parse_results.py results_crc32