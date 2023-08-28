#!/bin/bash

set -e

cd ../

# TEST 1 d256 i u500
data_size="256"
interval="500"
perl -e 'print "A"x256' > ./client1/root/payload.txt
echo 'ip link set eth0 address 00:00:0a:00:00:ff
ip link set eth1 address 00:00:0a:00:01:ff
ip link set eth2 address 00:00:0a:00:02:ff
ip link set eth3 address 00:00:0a:00:03:ff
ip link set eth4 address 00:00:0a:00:04:ff

chmod u+x /retrieve_info.sh

#P4_16 commands
p4c-bm2-ss /root/p4/program_withsha256_payload_256.p4 --emit-externs -o /root/p4/program_withsha256_payload_256.json
simple_switch -i 1@eth0 -i 2@eth1 -i 3@eth2 -i 4@eth3 /root/p4/program_withsha256_payload_256.json -- --load-modules=/root/p4/definition.so &

while [[ $(pgrep simple_switch) -eq 0 ]]; do sleep 1; done
until simple_switch_CLI <<< "help"; do sleep 1; done

simple_switch_CLI <<< $(cat commands.txt)' > ./router3.startup

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 2 d256 i u1000
interval="1000"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 3 d256 i u5000
interval="5000"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 4 d256 i u7500
interval="7500"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 5 d256 i u10000
interval="10000"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


############################################################################################################################################################################
# TEST 6 d512 i u500
data_size="512"
interval="500"
perl -e 'print "A"x512' > ./client1/root/payload.txt
echo 'ip link set eth0 address 00:00:0a:00:00:ff
ip link set eth1 address 00:00:0a:00:01:ff
ip link set eth2 address 00:00:0a:00:02:ff
ip link set eth3 address 00:00:0a:00:03:ff
ip link set eth4 address 00:00:0a:00:04:ff

chmod u+x /retrieve_info.sh

#P4_16 commands
p4c-bm2-ss /root/p4/program_withsha256_payload_512.p4 --emit-externs -o /root/p4/program_withsha256_payload_512.json
simple_switch -i 1@eth0 -i 2@eth1 -i 3@eth2 -i 4@eth3 /root/p4/program_withsha256_payload_512.json -- --load-modules=/root/p4/definition.so &

while [[ $(pgrep simple_switch) -eq 0 ]]; do sleep 1; done
until simple_switch_CLI <<< "help"; do sleep 1; done

simple_switch_CLI <<< $(cat commands.txt)' > ./router3.startup

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 7 d512 i u1000
interval="1000"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 8 d512 i u5000
interval="5000"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 9 d512 i u7500
interval="7500"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 10 d512 i u10000
interval="10000"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean



############################################################################################################################################################################
# TEST 11 d1024 i u500
data_size="1024"
interval="500"
perl -e 'print "A"x1024' > ./client1/root/payload.txt
echo 'ip link set eth0 address 00:00:0a:00:00:ff
ip link set eth1 address 00:00:0a:00:01:ff
ip link set eth2 address 00:00:0a:00:02:ff
ip link set eth3 address 00:00:0a:00:03:ff
ip link set eth4 address 00:00:0a:00:04:ff

chmod u+x /retrieve_info.sh

#P4_16 commands
p4c-bm2-ss /root/p4/program_withsha256_payload_1024.p4 --emit-externs -o /root/p4/program_withsha256_payload_1024.json
simple_switch -i 1@eth0 -i 2@eth1 -i 3@eth2 -i 4@eth3 /root/p4/program_withsha256_payload_1024.json -- --load-modules=/root/p4/definition.so &

while [[ $(pgrep simple_switch) -eq 0 ]]; do sleep 1; done
until simple_switch_CLI <<< "help"; do sleep 1; done

simple_switch_CLI <<< $(cat commands.txt)' > ./router3.startup

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 12 d1024 i u1000
interval="1000"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 13 d1024 i u5000
interval="5000"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 14 d1024 i u7500
interval="7500"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


# TEST 15 d1024 i u10000
interval="10000"

echo ""
echo "Starting kathara lab..."
kathara lstart --noterminals
#/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
sleep 2

echo ""
echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
  
for i in {1..60}; do
    sleep 1
    printf "\r   Test ends in $((60-${i})) seconds. "
done
kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

echo ""
echo "Saving results."
kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_sha256.txt

echo ""
echo "Stopping kathara lab..."
kathara lclean
#/usr/bin/time -o ./test/time_clean.txt -p kathara lclean


#################### Restoring files and saving results ####################
echo ""
echo "Restoring files and saving results..."
perl -e 'print "A"x256' > ./client1/root/payload.txt
echo 'ip link set eth0 address 00:00:0a:00:00:ff
ip link set eth1 address 00:00:0a:00:01:ff
ip link set eth2 address 00:00:0a:00:02:ff
ip link set eth3 address 00:00:0a:00:03:ff
ip link set eth4 address 00:00:0a:00:04:ff

chmod u+x /retrieve_info.sh

#P4_16 commands
p4c /root/p4/program.p4 -o /root/p4/
simple_switch -i 1@eth0 -i 2@eth1 -i 3@eth2 -i 4@eth3 -i 5@eth4 /root/p4/program.json &

while [[ $(pgrep simple_switch) -eq 0 ]]; do sleep 1; done
until simple_switch_CLI <<< "help"; do sleep 1; done

simple_switch_CLI <<< $(cat commands.txt)' > ./router3.startup

cd ./test
mkdir -p ./results_sha256
mv ./*_sha256.txt ./results_sha256/
rename 's/_sha256.txt/.txt/g' *
./parse_results.py results_sha256

echo ""
echo "Done."