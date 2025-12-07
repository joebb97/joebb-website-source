---
title: "Learning by doing: School Courses"
draft: false
author: Joey Buiteweg
---

I did a fair amount of hands-on learning via projects and labs in school. Listed are summaries of the applied work involved in some EECS (electrical engineering + computer science) courses I took.

The topics and work mentioned as part of each course are not exhaustive, nor is this a complete list of the EECS courses I took.

Sadly I can't share source code or implementation details in the spirit of keeping current University of Michigan students honest.

I'm hoping this catalog can help curious eyes get an idea of what goes into an EECS education.

### Undergrad

###### EECS 215: Analog Circuits

- Labs for learning the basics of AC and DC analog circuits using oscilloscopes, function generators, and breadboards.
- Matlab and LTSpice for homework assignments. Math used includes calculus, complex numbers, and mild linear algebra.

###### EECS 216: Signals and Systems

- Intermediate circuits course. Topics included:
	- Closed and open loop control systems
	- Time and frequency domains of signals
	- Filters
	- Amplitude and Frequency modulation
- Code written in Matlab for labs and homework assignments

###### EECS 270: Intro to Digital Logic Design

- All labs/projects completed in Verilog flashed onto an FPGA SoC with Switches, Push Buttons, and Hex Displays
- Synchronous and asynchronous designs, progression from logic gate level design up to Register Transfer Level
- Signed sum and difference calculator
- Various Finite State machines: Saturating counter, Traffic light controller
- Signal delay analysis

###### EECS 281: Data Structures and Algorithms

- All projects written in C++
- Letterman: A program to find paths between words, where steps in the path involve changes to the word's letters. Any combo of: swap letters, modify one letter, delete one letter
  - Application of Breadth First Search and Depth First Search through a dictionary of words
- SillyQL: A toy in-memory SQL implementation which utilized vectors, hash sets and-based BST sets.
- MineEscape: recursive 2D grid movement based on various implementations of a priority queue (sorted vector, binary heap, and pairing heap)
- Various solutions to dressed up representations of the Traveling Salesman Problem, the Knapsack Problem, and finding Minimum Spanning Trees
  - Implementations leverage Prim's algorithm and branch and bound algorithms.

###### EECS 370: Intro to Computer Architecture

- All projects written in C (for no good reason mind you)
- An assembler and simulator/emulator for a toy RISC machine called LC2K (little computer 2000)
- A software simulation of a pipelined implementation of LC2K.
- An updated assembler and linker of L2CK assembly programs that utilized symbol and relocation tables

###### EECS 373: Intro to Embedded Systems

- All labs and final project completed in combinations of ARM v7 thumb assembly, Verilog, and C
- Labs involving Memory Mapped IO, controlling a Servo Motor from an FPGA fabric, serial protocols (SPI, I2C, UART), various peripherals (i.e Accelerometers), interrupts and polling
- See parent page for our final project, Auto Otamatone

###### EECS 473: Advanced Embedded Systems

- Project and Labs completed in C and C++
- See parent page for our final project, Smart Rooms
- Labs involved:
  - Writing FreeRTOS tasks for Arduino and Raspberry Pi to investigating rate monotonic scheduling
  - A remote controlled car with a LCD screen driver using Zigbee protocol, Arduino, and DC motors
  - Linux device drivers and FreeRTOS tasks on the Raspberry Pi to control DC motors
  - A Computer Vision ping-pong ball chasing car (basically the wheels would turn if it saw the ping-pong ball, nothing fancy like SLAM)

###### EECS 485: Web Systems

- Projects written Python and Javascript
- Static site-generator utilizing JSON files and Jinja2 Templates
- Fake instagram app using server-side dynamic pages (Flask, SQL, and Jinja2)
- Same instagram app using client-side dynamic pages (Flask, SQL, and React)
- Map-Reduce main work coordinator and worker nodes (implemented as separate Python processes, not separate machines
- Hadoop pipeline to construct inverted index for primitive search engine (no crawler, documents came from large blob of wikipedia articles). Search Engine frontend in React, backend in Flask + SQL. Pagerank and tf-idf used for returning results

###### EECS 482: Operating Systems

- Projects written in C++
- Concurrent thread program simulating accesses to different sectors of a disk
- Userspace thread library with support for "multiple CPUs" (these were implemented by the instructors as pthreads calling the clients of the library we wrote). Implemented with `ucontext`. These userspace threads are commonly called [fibers](https://www.evanjones.ca/software/threading.html), where scheduling is done by the library upon calls to `mutex`, `cv`, and `yield` operations --- not the kernel. Some call these stackful coroutines, although definitions vary. I will write about these definitons and link to that here at some point. There was no event loop either, only calls to `setcontext` and `swapcontext`.
- A Virtual Memory Pager
- A Shared Network File System ("shanty google drive") based on BSD TCP Sockets, inodes and directory + file locks.

###### EECS 489: Computer Networks

- Projects written in C and C++ with BSD sockets as well as some Python scripts for automated testing with Mininet
- Our own implementation of `iperf`, which measures throughput of a TCP connection between network nodes.
- A CDN-like Forward HTTP Proxy that selects appropriate bitrate chunks of a video file requested by various clients. Concurrency implemented with a primitive event loop based on `select`.
- A reliable file-transfer client and server using UDP to implement two sliding-window protocols, Cumulative Acknowledgement and Selective Acknowledgement
- The logic of a basic, static router with a static routing table. Supported ARP, IP Packets and ICMP

###### EECS 491: Distributed Systems

- Projects written in Golang
- A Map-Reduce main coordinator (using goroutines instead of network nodes)
- A Fault Tolerant Key-Value Store (a la NoSQL database) using Primary Backup replication
- A Key-Value store backed by an implementation of Multi-Paxos
- A non-Fault Tolerant Distributed Hash Table using Consistent Hashing
- A Strictly Serialized Key-Value Store using Multi-Paxos and Sharding

### Grad

###### EECS 582: Advanced Operating Systems

- Read and discussed assigned system design research papers
- I presented Google's [Spanner](https://youtu.be/k7hXSACSS6M)
- Made improvements to the [angr symbolic execution engine](https://github.com/angr) by porting a faster memory model [memsight](https://github.com/season-lab/memsight) and its dependencies to Python 3, allowing compatibility with the latest versions of angr.
  - Here's the [paper we wrote](https://drive.google.com/file/d/1QPO8mytpKYQLwhYYpV3QQgqswOGNI-N8/view?usp=sharing)
  - Here's a [presentation](https://drive.google.com/file/d/1e4nfUz-Yt6OpAKQh-TBQUEMvruLs1imW/view?usp=sharing) my teammates and I made for our project

###### EECS 586: Algorithms

- Homework sets involving proofs of Algorithms concepts
- I did learn about P and NP in this class which was the most enjoyable part

###### EECS 588: Advanced Computer Security

- Read and discussed assigned papers in side-channel research
- I presented the [ARMageddon Cache Attack Paper](https://drive.google.com/file/d/1JtojNQMeBst_WjY6bOv2ZyxAjr3RGuMD/view?usp=sharing)
- Implemented the [Cache Template Attacks](https://www.usenix.org/system/files/conference/usenixsecurity15/sec15-paper-gruss.pdf) using the Flush+Flush and Flush+Reload side-channel primitives
  - Here's our [project writeup](https://drive.google.com/file/d/1UlQ3ZcLV9ojJhBk7LCD0l9Tr962oMMyW/view?usp=sharing)

###### EECS 592: Artificial Intelligence

- Homework sets implemented in Python and exams related to AI concepts like Search, Game Theory, Bayesian Networks, Decision Trees, among other topics
