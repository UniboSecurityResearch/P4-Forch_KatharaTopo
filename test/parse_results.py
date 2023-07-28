#!/usr/bin/python3

import os, re, sys
from statistics import stdev, variance         

def extract_results():
    results = {}

    if len(sys.argv) == 2:
        directory = './' + sys.argv[1] + '/'
    else:
        directory = './'

    for filename in os.listdir(directory):
        f = os.path.join(directory, filename)
        if os.path.isfile(f) and filename.startswith('results_d'):
            results[f] = {}
            with open(f, "r") as results_file:
                match = re.findall("RuntimeCmd: packet_processing_time_array= .*", results_file.read())
                packet_processing_time_array = str(match).replace("RuntimeCmd: packet_processing_time_array= ", "").replace(" ","").replace("']","").replace("['","").split(",")
                packet_processing_time_array = list(map(lambda x: float(x), packet_processing_time_array))
                results[f]["packet_processing_time_array_avg"] = sum(packet_processing_time_array) / len(packet_processing_time_array)
                results[f]["packet_processing_time_array_min"] = min(packet_processing_time_array)
                results[f]["packet_processing_time_array_max"] = max(packet_processing_time_array)
                results[f]["packet_processing_time_array_std"] = stdev(packet_processing_time_array)
                results[f]["packet_processing_time_array_variance"] = variance(packet_processing_time_array)

                results_file.seek(0)
                match = re.findall("RuntimeCmd: packet_dequeuing_timedelta_array= .*", results_file.read())
                packet_dequeuing_timedelta_array = str(match).replace("RuntimeCmd: packet_dequeuing_timedelta_array= ", "").replace(" ","").replace("']","").replace("['","").split(",")
                packet_dequeuing_timedelta_array = list(map(lambda x: float(x), packet_dequeuing_timedelta_array))
                results[f]["packet_dequeuing_timedelta_array_avg"] = sum(packet_dequeuing_timedelta_array) / len(packet_dequeuing_timedelta_array)
                results[f]["packet_dequeuing_timedelta_array_min"] = min(packet_dequeuing_timedelta_array)
                results[f]["packet_dequeuing_timedelta_array_max"] = max(packet_dequeuing_timedelta_array)
                results[f]["packet_dequeuing_timedelta_array_std"] = stdev(packet_dequeuing_timedelta_array)
                results[f]["packet_dequeuing_timedelta_array_variance"] = variance(packet_dequeuing_timedelta_array)
    return results



def write_results_on_file(results):
    crc=''
    if "crc16" in str(results.keys()):
        crc='_crc16'
    elif "crc32" in str(results.keys()):
        crc='_crc32'

    if len(sys.argv) == 2:
        directory = './' + sys.argv[1] + '/'
    else:
        directory = './'

    with open(directory + "results_packet_processing_time" + crc + ".csv", "w") as packet_processing_time_file:
        packet_processing_time_file.write("d,i,avg,min,max,std,variance\n")

    with open(directory + "results_packet_dequeuing_timedelta" + crc + ".csv", "w") as packet_dequeuing_timedelta_file:
        packet_dequeuing_timedelta_file.write("d,i,avg,min,max,std,variance\n")

    for filename in sorted(results.keys()):
        d=filename.split('results_d')[1].split('_')[0]
        i=filename.split('results_d'+d+'_i')[1].split('.txt')[0]
        if crc != '':
            i=i.split('_'+crc)[0]

        with open(directory + "results_packet_processing_time" + crc + ".csv", "a") as packet_processing_time_file:
            packet_processing_time_file.write("%s,%s,%s,%s,%s,%s,%s\n" % (d, i, results[filename]["packet_processing_time_array_avg"],
                                                                            results[filename]["packet_processing_time_array_min"],
                                                                            results[filename]["packet_processing_time_array_max"],
                                                                            results[filename]["packet_processing_time_array_std"],
                                                                            results[filename]["packet_processing_time_array_variance"]))
        with open(directory + "results_packet_dequeuing_timedelta" + crc +".csv", "a") as packet_dequeuing_timedelta_file:
            packet_dequeuing_timedelta_file.write("%s,%s,%s,%s,%s,%s,%s\n" % (d, i, results[filename]["packet_dequeuing_timedelta_array_avg"],
                                                                            results[filename]["packet_dequeuing_timedelta_array_min"],
                                                                            results[filename]["packet_dequeuing_timedelta_array_max"],
                                                                            results[filename]["packet_dequeuing_timedelta_array_std"],
                                                                            results[filename]["packet_dequeuing_timedelta_array_variance"]))

 

if __name__ == "__main__":
    test_results = extract_results()
    write_results_on_file(test_results)