#!/bin/bash

./test_network.sh -d 256 -i 1 --crc16
./test_network.sh -d 512 -i 1 --crc16
./test_network.sh -d 1024 -i 1 --crc16

./test_network.sh -d 256 -i 10 --crc16
./test_network.sh -d 512 -i 10 --crc16
./test_network.sh -d 1024 -i 10 --crc16

./test_network.sh -d 256 -i 100 --crc16
./test_network.sh -d 512 -i 100 --crc16
./test_network.sh -d 1024 -i 100 --crc16

./test_network.sh -d 256 -i 1000 --crc16
./test_network.sh -d 512 -i 1000 --crc16
./test_network.sh -d 1024 -i 1000 --crc16

./test_network.sh -d 256 -i 5000 --crc16
./test_network.sh -d 512 -i 5000 --crc16
./test_network.sh -d 1024 -i 5000 --crc16

./test_network.sh -d 256 -i 7500 --crc16
./test_network.sh -d 512 -i 7500 --crc16
./test_network.sh -d 1024 -i 7500 --crc16

./test_network.sh -d 256 -i 10000 --crc16
./test_network.sh -d 512 -i 10000 --crc16
./test_network.sh -d 1024 -i 10000 --crc16

./parse_results.py results_crc16