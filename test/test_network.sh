#!/bin/bash

set -e


usage()
{
    echo "usage: ./test_network.sh [[-d data_size -i interval] [--crc] | [-h]]"
}

test()
{   
    cd ../
    if [[ "$crc" == "true" && "$data_size" -eq 256 ]]
    then
        sed -i -e 's|program|program_withcrc_payload_256|' ./router3.startup
        perl -e 'print "A"x256' > ./client1/root/payload.txt
    fi
    if [[ "$crc" == "true" && "$data_size" -eq 512 ]]
    then
        sed -i -e 's|program|program_withcrc_payload_512|' ./router3.startup
        perl -e 'print "A"x512' > ./client1/root/payload.txt
    fi
    if [[ "$crc" == "true" && "$data_size" -eq 1024 ]]
    then
        sed -i -e 's|program|program_withcrc_payload_1024|' ./router3.startup
        perl -e 'print "A"x1024' > ./client1/root/payload.txt
    fi

    
    echo ""
    echo "Starting kathara lab..."
    kathara lstart --noterminals
    #/usr/bin/time -o ./test/time_start.txt -p kathara lstart --noterminals

    while [[ ! -f ./shared/ta.key ]]; do sleep 1; done
    sleep 2

    echo ""
    echo "Testing lab with packet of size of ${data_size} bytes and interval of ${interval} microseconds."
    if [[ "$crc" == "true" ]]
    then
        echo "CRC enabled."
        kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval} --file /root/payload.txt" --no-stdout --no-stderr &
    else
        kathara exec client1 "hping3 -d ${data_size} 192.168.1.1 -i u${interval}" --no-stdout --no-stderr &
    fi
    
    for i in {1..60}; do
        sleep 1
        printf "\r   Test ends in $((60-${i})) seconds. "
    done
    kill $(ps -aux | grep "kathara exec client1 hping3" | awk '{print $2}' | head -1)

    echo ""
    echo "Saving results."
    kathara exec router3 "./retrieve_info.sh" --no-stdout --no-stderr
    
    if [[ "$crc" == "true" ]]
    then
        mv ./shared/results.txt ./test/results_d${data_size}_i${interval}_crc.txt
    else
        mv ./shared/results.txt ./test/results_d${data_size}_i${interval}.txt
    fi

    echo ""
    echo "Stopping kathara lab..."
    kathara lclean
    #/usr/bin/time -o ./test/time_clean.txt -p kathara lclean

    if [[ "$crc" == "true" && "$data_size" -eq 256 ]]
    then
        sed -i -e 's|program_withcrc_payload_256|program|' ./router3.startup
    fi
    if [[ "$crc" == "true" && "$data_size" -eq 512 ]]
    then
        sed -i -e 's|program_withcrc_payload_512|program|' ./router3.startup
    fi
    if [[ "$crc" == "true" && "$data_size" -eq 1024 ]]
    then
        sed -i -e 's|program_withcrc_payload_1024|program|' ./router3.startup
    fi

    echo ""
    echo "Done."
}


data_size=""
interval=""
crc=""

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
        --crc )       
            crc="true"
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