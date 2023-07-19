FROM xtrm0/quagga
RUN apt-get update && apt-get install -y iperf3
RUN apt-get install -y hping3
RUN apt-get install -y python3-pip
RUN pip3 install asyncua