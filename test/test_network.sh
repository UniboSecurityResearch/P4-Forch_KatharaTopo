#!/bin/bash

set -e


usage()
{
    echo "usage: ./test_network.sh [[-d data_size -i interval] [--crc16] [--crc32] [--xxh64]| [-h]]"
}

test()
{   
    cd ../
    if [[ "$data_size" -eq 256 ]]
    then
        perl -e 'print "A"x256' > ./client1/root/payload.txt
        sed -i -e 's|program|program_payload_256|' ./router3.startup
    fi
    if [[ "$data_size" -eq 512 ]]
    then
        perl -e 'print "A"x512' > ./client1/root/payload.txt
        sed -i -e 's|program|program_payload_512|' ./router3.startup
    fi
    if [[ "$data_size" -eq 1024 ]]
    then
        perl -e 'print "A"x1024' > ./client1/root/payload.txt
        sed -i -e 's|program|program_payload_1024|' ./router3.startup
    fi

    if [[ "$crc16" == "true" && "$data_size" -eq 256 ]]
    then
        sed -i -e 's|program_payload_256|program_withcrc16_payload_256|' ./router3.startup
    fi
    if [[ "$crc16" == "true" && "$data_size" -eq 512 ]]
    then
        sed -i -e 's|program_payload_512|program_withcrc16_payload_512|' ./router3.startup
    fi
    if [[ "$crc16" == "true" && "$data_size" -eq 1024 ]]
    then
        sed -i -e 's|program_payload_1024|program_withcrc16_payload_1024|' ./router3.startup
    fi

    if [[ "$crc32" == "true" && "$data_size" -eq 256 ]]
    then
        sed -i -e 's|program_payload_256|program_withcrc32_payload_256|' ./router3.startup
    fi
    if [[ "$crc32" == "true" && "$data_size" -eq 512 ]]
    then
        sed -i -e 's|program_payload_512|program_withcrc32_payload_512|' ./router3.startup
    fi
    if [[ "$crc32" == "true" && "$data_size" -eq 1024 ]]
    then
        sed -i -e 's|program_payload_1024|program_withcrc32_payload_1024|' ./router3.startup
    fi

    if [[ "$xxh64" == "true" && "$data_size" -eq 256 ]]
    then
        sed -i -e 's|p4c /root/p4/program_payload_256.p4 -o /root/p4/|#p4c /root/p4/program.p4 -o /root/p4/|' ./router3.startup
        sed -i -e 's|/root/p4/program_payload_256.json|/root/p4/program_withxxhash64_payload_256.json|' ./router3.startup
    fi
    if [[ "$xxh64" == "true" && "$data_size" -eq 512 ]]
    then
        sed -i -e 's|p4c /root/p4/program_payload_512.p4 -o /root/p4/|#p4c /root/p4/program.p4 -o /root/p4/|' ./router3.startup
        sed -i -e 's|/root/p4/program_payload_512.json|/root/p4/program_withxxhash64_payload_512.json|' ./router3.startup
    fi
    if [[ "$xxh64" == "true" && "$data_size" -eq 1024 ]]
    then
        sed -i -e 's|p4c /root/p4/program_payload_1024.p4 -o /root/p4/|#p4c /root/p4/program.p4 -o /root/p4/|' ./router3.startup
        sed -i -e 's|/root/p4/program_payload_1024.json|/root/p4/program_withxxhash64_payload_1024.json|' ./router3.startup
    fi
    
    echo ""
    echo "Starting kathara lab..."
    kathara lstart --noterminals
    #/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

    while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
    sleep 2

    echo ""
    echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
    if [[ "$crc16" == "true" ]]
    then
        echo "CRC16 enabled."
        kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
    elif [[ "$crc32" == "true" ]]
    then
        echo "CRC32 enabled."
        kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
    elif [[ "$xxh64" == "true" ]]
    then
        echo "XXH64 enabled."
        kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
    else
        kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
    fi
    
    for i in {1..60}; do
        sleep 1
        printf "\r   Test ends in $((60-${i})) seconds. "
    done
    kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

    echo ""
    echo "Saving results."
    kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
    if [[ "$crc16" == "true" ]]
    then
        mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_crc16.txt
    elif [[ "$crc32" == "true" ]]
    then
        mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_crc32.txt
    elif [[ "$xxh64" == "true" ]]
    then
        mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_xxh64.txt
    else
        mv ./shared/results.txt ./test/results_d${data_size}_i${interval}.txt
    fi

    echo ""
    echo "Stopping kathara lab..."
    kathara lclean
    #/usr/bin/time -o ./test/time_clean.txt -p kathara lclean

    if [[ "$crc16" == "" && "$crc32" == "" && "$xxh64" == "" ]]
    then
        sed -i -e 's|program_payload_256|program|' ./router3.startup
        sed -i -e 's|program_payload_512|program|' ./router3.startup
        sed -i -e 's|program_payload_1024|program|' ./router3.startup
    fi

    if [[ "$crc16" == "true" ]]
    then
        sed -i -e 's|program_withcrc16_payload_256|program|' ./router3.startup
        sed -i -e 's|program_withcrc16_payload_512|program|' ./router3.startup
        sed -i -e 's|program_withcrc16_payload_1024|program|' ./router3.startup
    fi

    if [[ "$crc32" == "true" ]]
    then
        sed -i -e 's|program_withcrc32_payload_256|program|' ./router3.startup
        sed -i -e 's|program_withcrc32_payload_512|program|' ./router3.startup
        sed -i -e 's|program_withcrc32_payload_1024|program|' ./router3.startup
    fi

    if [[ "$xxh64" == "true" ]]
    then
        sed -i -e 's|#p4c /root/p4/program.p4 -o /root/p4/|p4c /root/p4/program.p4 -o /root/p4/|' ./router3.startup
        sed -i -e 's|program_withxxhash64_payload_256|program|' ./router3.startup
        sed -i -e 's|program_withxxhash64_payload_512|program|' ./router3.startup
        sed -i -e 's|program_withxxhash64_payload_1024|program|' ./router3.startup
    fi

    cd ./test

    if [[ "$crc32" == "true" ]]
    then
        mkdir -p ./results_crc32
        mv ./results_d${data_size}_i${interval}_crc32.txt ./results_crc32/results_d${data_size}_i${interval}.txt
    elif [[ "$crc16" == "true" ]]
    then
        mkdir -p ./results_crc16
        mv ./results_d${data_size}_i${interval}_crc16.txt ./results_crc16/results_d${data_size}_i${interval}.txt
    elif [[ "$xxh64" == "true" ]]
    then
        mkdir -p ./results_xxh64
        mv ./results_d${data_size}_i${interval}_xxh64.txt ./results_xxh64/results_d${data_size}_i${interval}.txt
    else 
        mkdir -p ./results_no_crc
        mv ./results_d${data_size}_i${interval}.txt ./results_no_crc/results_d${data_size}_i${interval}.txt
    fi

    echo ""
    echo "Done."
}


data_size=""
interval=""
crc16=""
crc32=""
xxh64=""

while [ "$1" != "" ]; do
    case $1 in
        -d | --data )       
            shift
            if [[ "$1" -eq 256 || "$1" -eq 512 || "$1" -eq 1024 ]]
            then
                data_size=$1
            fi
        ;;
        -i | --interval )       
            shift
            if [[ "$1" -ge 0 ]]
            then
                interval=$1
            fi
        ;;
        --crc16 )       
            crc16="true"
        ;;
        --crc32 )       
            crc32="true"
        ;;
        --xxh64 )       
            xxh64="true"
        ;;
        -h | --help )           
            usage
            exit
        ;;
        * )                     
            usage
            exit 1
        ;;
    esac
    shift
done

if [[ "$data_size" != "" || "$interval" != "" ]]
then
    test
else
    usage
fi