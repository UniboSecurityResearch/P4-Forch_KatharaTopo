#!/bin/bash

echo "packet_processing_time_array: " > /shared/results.txt
echo "register_read packet_processing_time_array" | simple_switch_CLI >> /shared/results.txt

echo "" >> /shared/results.txt
echo "packet_enqueuing_depth_array: " >> /shared/results.txt
echo "register_read packet_enqueuing_depth_array" | simple_switch_CLI >> /shared/results.txt

echo "" >> /shared/results.txt
echo "packet_dequeuing_timedelta_array: " >> /shared/results.txt
echo "register_read packet_dequeuing_timedelta_array" | simple_switch_CLI >> /shared/results.txt

echo "" >> /shared/results.txt
echo "packet_dequeuing_depth_array: " >> /shared/results.txt
echo "register_read packet_dequeuing_depth_array" | simple_switch_CLI >> /shared/results.txt