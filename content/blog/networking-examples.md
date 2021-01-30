---
title: "Simple Networking Applications in Rust and Golang"
date: 2021-01-30
draft: false
toc: true
categories: [rust, golang]
author: Joey Buiteweg
---

# The Premise

I wanted to be more comfortable and competent with the provided networking libraries in Rust and Golang. I figured implementing some simple client/server applications would be a great way to do this.


# The Applications

## Echo Server

I implemented a simple Echo Server and Client in both Rust and Go.

Here is the [Rust source code](https://github.com/joebb97/sandbox/tree/master/rust/echo_net)

And here is the [Go source code](https://github.com/joebb97/sandbox/tree/master/go/src/echo_net)

Both implementations support the same functionality which is sending either TCP or UDP messages from a client to a server and having the server "echo" back whatever the client sent.

An example run looks like this

```bash
# Server output
$ go run echo_net.go -s
2021/01/30 14:56:45 Listening on [::]:5001 using tcp
2021/01/30 14:57:15 Accepted a connection request.
hey there
you handsome devil
Yay networking!
```

```bash
# Client output
$ go run echo_net.go -c
2021/01/30 14:57:15 Dialing localhost:5001 using tcp
hey there
hey there
you handsome devil
you handsome devil
Yay networking!
Yay networking!
```

Each line appears twice in the client output because the first one is the user entering the message while the second is the server's respone.

The command line flags can also be used to specify alternative hostnames/IP addresses, ports, and a buffer size used store the messages sent and received.

For brevity, I'll showcase the key TCP and UDP client/server code for the Go implementation. Feel free to check out the UDP implementations in both languages.

Here's the TCP Server connection handling code,
```go
// TCP Server Handling Connection
func handleConnection(conn net.Conn, bufSize uint) {
	buf := make([]byte, bufSize)
	defer conn.Close()
	for {
		size, err := conn.Read(buf)
		switch {
		case err == io.EOF:
			log.Println("Connection reached EOF, closing.\n ---")
			return
		case err != nil:
			log.Println("Error receiving message from connection\n", err)
			return
		}
		msg := string(buf[:size])
		fmt.Println(msg)
		conn.Write(buf[:size])
	}
}
```
And the UDP server connection handling code,
```go
func handleConnectionUDP(conn *net.UDPConn, bufSize uint) {
	buf := make([]byte, bufSize)
	for {
		size, remoteAddr, err := conn.ReadFromUDP(buf)
		switch {
		case err == io.EOF:
			log.Println("Connection reached EOF, closing.\n ---")
			return
		case err != nil:
			log.Println("Error receiving message from connection\n", err)
			return
		}
		msg := string(buf[:size])
		fmt.Println(msg)
		conn.WriteToUDP(buf[:size], remoteAddr)
	}
}
```

And finally the TCP and UDP Client connection handling code.
```go
// TCP and UDP Client Connection Code
func runClient(flags *Flags) error {
	wholeAddr := flags.addr + ":" + flags.port
	conn, err := Open(flags.protoStr, wholeAddr)
	if err != nil {
		return errors.Wrap(err, "Client: Failed to open connection to "+wholeAddr)
	}
	stdinReader := bufio.NewReader(os.Stdin)
	bufSize, _ := strconv.Atoi(flags.bufSize)
	buf := make([]byte, uint(bufSize))
	for {
		text, stdinErr := stdinReader.ReadString('\n')
		if stdinErr != nil {
			return errors.Wrap(stdinErr, "Couldn't read from stdin")
		}
		text = text[:len(text)-1]
		_, err := conn.Write([]byte(text))
		if err != nil {
			return errors.Wrap(err, "Couldn't write message to server")
		}
		replySize, err := conn.Read(buf)
		// Don't print the newline
		fmt.Println(string(buf[:replySize]))
	}
}
```

I enjoyed how the same client code mostly worked for both TCP and UDP (the `Open` function is different), which is a sign of good API design!

## Iperf

`iperf` is a [network utility](https://linuxhint.com/iperf_command_usage/) used for measuring throughput between two networked devices. I'd written a novel implementation of the tool in C++ for a class before, so I was interested to see what a Golang implementation would look like.

My Go implementation supports the same functionality as the normal iperf (written in C), which allows for profiling throughput between two devices over UDP and TCP.

I haven't made a Rust implementation yet, but am planning to in the near future

Here is an example run of the tool.

```bash
# Server output
$ go run iperf.go -s -b 131072
Listening on [::]:5001 using TCP
Received 29369565 KB in 10.00017095 seconds (rate=23495.250 Mbps) from [::1]:54716
```

```bash
# Client output
$ go run iperf.go -c -t 10 -b 131072
Dialing localhost:5001 using TCP
```

As we can see the tool measured ~23.5Gbps of throughput from one process to another on my laptop, which is definitely sensible.

The `-b` parameter specifies the underlying buffer size to use when storing/sending packets. I found that using a size of 128Kb yielded more accurate measured throughput (compared to the regular `iperf`.

This is much larger than it should be and is probably necessary due to some ineffeciency that I don't really care to investigate. I'll be interested to see if the same behavior surfaces in the Rust implementation I'm planning on making.

The command line flags support the same functionality as the Echo Server/Client, as well as specifying how long the client should send for (with the `-t` flag). 

I'll again showcase the key pieces of code for the server and client.

```go
// TCP and UDP Server Connection Handling
func handleConnection(conn net.Conn, bufSize uint, protoStr string) {
	buf := make([]byte, bufSize)
	if protoStr == "tcp" {
		defer conn.Close()
	}
	var remoteAddr *net.UDPAddr
	totalRecvd := 0
	startTime := time.Now()
	var size int
	var err error
	for {
		if remoteAddr == nil && protoStr == "udp" {
			size, remoteAddr, err = conn.(*net.UDPConn).ReadFromUDP(buf)
			startTime = time.Now()
		} else {
			size, err = conn.Read(buf)
		}
		switch {
		case err == io.EOF:
			fmt.Println("Connection reached EOF, closing.\n ---")
			return
		case err != nil:
			fmt.Println("Error receiving message from connection\n", err)
			return
		}
		totalRecvd += size
		if buf[size-1] == endbyte {
			break
		}
	}
	duration := time.Since(startTime).Seconds()
	var addr interface{}
	if protoStr == "udp" {
		addr = remoteAddr
	} else {
		addr = conn.RemoteAddr()
	}
	kiloBytes := int(float64(totalRecvd) / math.Pow10(3))
	megaBitsPerSecond := (float64(totalRecvd) * 8.0 / math.Pow10(6)) / duration
	fmt.Printf("Received %+v KB in %+v seconds (rate=%.3f Mbps) from %+v\n",
		kiloBytes, duration, megaBitsPerSecond, addr)
}
```

And here is the client code
```go
// TCP/UDP Client Connection Handling
func runClient(flags *Flags) error {
	wholeAddr := flags.addr + ":" + flags.port
	conn, err := Open(flags.protoStr, wholeAddr)
	if err != nil {
		return err
	}
	defer conn.Close()
	bufSize, _ := strconv.Atoi(flags.bufSize)
	buf := bytes.Repeat([]byte{0}, bufSize)
	totalSent := 0

	duration, _ := strconv.Atoi(flags.duration)
	endTime := time.Now().Add(time.Second * time.Duration(duration))
	for time.Now().Before(endTime) {
		bytesSent, err := conn.Write(buf)
		if err != nil {
			return errors.Wrap(err, "Couldn't write message to server")
		}
		totalSent += bytesSent
	}
	buf[0] = endbyte
	if flags.protoStr == "tcp" {
		_, err = conn.Write(buf[:1])
		if err != nil {
			return errors.Wrap(err, "Couldn't write message to server")
		}
	} else if flags.protoStr == "udp" {
		_, err = conn.Write(buf[:1])
		if err != nil {
			return errors.Wrap(err, "Couldn't write message to server")
		}
		// TODO: Do more sophisticated connection closing
		// The ending packet that was just sent isn't guaranteed to make it
		// to the server

		// Server should only send back one byte END message
		// recvBuf := []byte{0}
		// for recvBuf[0] != endbyte {
		// 	_, err = conn.Read(recvBuf)
		// 	if err != nil {
		// 		return errors.Wrap(err, "Couldn't write message to server")
		// 	}
		// }

	}
	return nil
}
```

As the TODO in the client code notes, the connection closing for UDP isn't failure proof and could certainly be improved for more reliability. If the last UDP packet sent by the client for closing the connection gets lost, the server will think the connection is still open! Definitely a problematic situation.

Handling this situation would require implementing a TCP-like connection termination process which I don't have the desire to write myself.


## Conclusion

This was a great exercise to get me accustomed to some different networking libraries, since up until now most of my socket level programming had been done in C++ and Python. I found my prior knowledge in these languages helped a lot in these implementaitons as well, since the syscall wrappers are mostly named the same and perform the same tasks.

Hope the article was useful, and happy coding!

I found the exercise to be both rewarding and useful!
