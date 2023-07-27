#!/bin/bash

./test_network.sh -d 256 -i 1 --crc
./test_network.sh -d 512 -i 1 --crc
./test_network.sh -d 1024 -i 1 --crc

./test_network.sh -d 256 -i 10 --crc
./test_network.sh -d 512 -i 10 --crc
./test_network.sh -d 1024 -i 10 --crc

./test_network.sh -d 256 -i 100 --crc
./test_network.sh -d 512 -i 100 --crc
./test_network.sh -d 1024 -i 100 --crc

./test_network.sh -d 256 -i 1000 --crc
./test_network.sh -d 512 -i 1000 --crc
./test_network.sh -d 1024 -i 1000 --crc

./test_network.sh -d 256 -i 5000 --crc
./test_network.sh -d 512 -i 5000 --crc
./test_network.sh -d 1024 -i 5000 --crc

./test_network.sh -d 256 -i 7500 --crc
./test_network.sh -d 512 -i 7500 --crc
./test_network.sh -d 1024 -i 7500 --crc

./test_network.sh -d 256 -i 10000 --crc
./test_network.sh -d 512 -i 10000 --crc
./test_network.sh -d 1024 -i 10000 --crc