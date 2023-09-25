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
kathara lstop
```


<!-- ### Header 3

```bash
echo "ciao"
```

```ruby
# Ruby code with syntax highlighting
GitHubPages::Dependencies.gems.each do |gem, version|
  s.add_dependency(gem, "= #{version}")
end
```

#### Header 4

*   This is an unordered list following a header.
*   This is an unordered list following a header.
*   This is an unordered list following a header.

##### Header 5

1.  This is an ordered list following a header.
2.  This is an ordered list following a header.
3.  This is an ordered list following a header.

###### Header 6

| head1        | head two          | three |
|:-------------|:------------------|:------|
| ok           | good swedish fish | nice  |
| out of stock | good and plenty   | nice  |
| ok           | good `oreos`      | hmm   |
| ok           | good `zoute` drop | yumm  |

### There's a horizontal rule below this.

* * *

### Here is an unordered list:

*   Item foo
*   Item bar
*   Item baz
*   Item zip

### And an ordered list:

1.  Item one
1.  Item two
1.  Item three
1.  Item four

### And a nested list:

- level 1 item
  - level 2 item
  - level 2 item
    - level 3 item
    - level 3 item
- level 1 item
  - level 2 item
  - level 2 item
  - level 2 item
- level 1 item
  - level 2 item
  - level 2 item
- level 1 item

### Small image

![Octocat](https://github.githubassets.com/images/icons/emoji/octocat.png)

### Large image

![Branching](https://guides.github.com/activities/hello-world/branching.png)


### Definition lists can be used with HTML syntax.

<dl>
<dt>Name</dt>
<dd>Godzilla</dd>
<dt>Born</dt>
<dd>1952</dd>
<dt>Birthplace</dt>
<dd>Japan</dd>
<dt>Color</dt>
<dd>Green</dd>
</dl>

```
Long, single-line code blocks should not wrap. They should horizontally scroll if they are too long. This line should be long enough to demonstrate this.
```

```
The final element. -->
```
