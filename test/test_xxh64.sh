#!/bin/bash

./test_network.sh -d 256 -i 500 --xxh64
./test_network.sh -d 512 -i 500 --xxh64
./test_network.sh -d 1024 -i 500 --xxh64

./test_network.sh -d 256 -i 1000 --xxh64
./test_network.sh -d 512 -i 1000 --xxh64
./test_network.sh -d 1024 -i 1000 --xxh64

./test_network.sh -d 256 -i 5000 --xxh64
./test_network.sh -d 512 -i 5000 --xxh64
./test_network.sh -d 1024 -i 5000 --xxh64

./test_network.sh -d 256 -i 7500 --xxh64
./test_network.sh -d 512 -i 7500 --xxh64
./test_network.sh -d 1024 -i 7500 --xxh64

./test_network.sh -d 256 -i 10000 --xxh64
./test_network.sh -d 512 -i 10000 --xxh64
./test_network.sh -d 1024 -i 10000 --xxh64

./parse_results.py results_xxh64