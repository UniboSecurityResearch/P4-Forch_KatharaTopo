---
layout: default
---

<!-- Text can be **bold**, _italic_, or ~~strikethrough~~.

There should be whitespace between paragraphs.

There should be whitespace between paragraphs. We recommend including a README, or a file with information about your project. -->

# Use case description: remote maintenance
Let us imagine a scenario in which a specialized worker requires to establish a connection from the Internet to the industrial plant, e.g. using video streaming. This repo is designed to put this connection in place, and to solve the problem of automating safe connection to the OT while taking into account threats to the security and privacy of the information sent outside the private network of the company.

## Description

The topology was developed in [Kathara](https://www.kathara.org/), an open source project to deploy virtual networks. 

![Topology](/assets/images/Forch-Industrial-Topo.png)

On the IT, we place our network orchestrator FORCH and the VPN server to connect to the OT. 

On the OT network, a P4 switch is connected to 2 OPC UA servers that control cameras. Now, the orchestrator can choose to deploy the connection directly using the P4 programmable switch (network offloading) or with the help of edge nodes.

## Run the example

To start the topology, from the root of the folder run:
```bash
kathara lstart --noterminals
```

On a terminal, to access a host, from the root of the folder run:
```bash
kathara connect client1
```

Then, to test if the VPN is set and ping the camera, from the client1 terminal run:
```bash
ping 192.168.1.1
```

To stop the topology, run:
```bash
kathara lclean
```
