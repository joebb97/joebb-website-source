---
title: "A Small Concurrency Example in Various Languages"
date: 2020-12-22
draft: false
toc: true
categories: [python, rust, golang, cpp]
author: Joey Buiteweg
---

## The Premise

A common introduction to concurrency is the simple task of spawning two threads, then printing "ping" and "pong" in order N (N = 5 in the following examples) times.

This task is a light intoduction to synchronization primitives like mutexes and condition variables, or in more modern-concurrency models, channels / thread-safe queues.

I figured it'd be interesting to see what this task looks like in different programming languages, so I decided to code it in my four favorite programming languages (python, rust, golang, c++, in that order) to get a sense of their concurrency libraries.

My methodology was to only use native concurrency primitives supported by the languages. Additionally, if a language supported message-passing concurrency via channels as well as traditional Hoare monitors, I wrote an implementation with both models.

Let's now take a look at the examples. The source code is available in my [sandbox monorepo](https://github.com/joebb97/sandbox)(just run `$ find . -name ping_pong -type d` to locate the specific directories).

## Golang

One of Go's best features is its beautiful and simple message-passing concurrency via channels. The message-passing code looks like this:

```golang {linenos=table}
// main.go
package main

import (
	"fmt"
	"sync"
)

func mainChannels() {
	numTimes := 5
	var wg sync.WaitGroup
	theChannel := make(chan string)

	// Ping thread
	wg.Add(2)
	go func(n int) {
		defer wg.Done()
		for i := 0; i < n; i++ {
			fmt.Println(<-theChannel)
			theChannel <- "pong"
		}
	}(numTimes)

	// Pong thread
	go func(n int) {
		defer wg.Done()
		for i := 0; i < n; i++ {
			theChannel <- "ping"
			fmt.Println(<-theChannel)
		}
	}(numTimes)

	wg.Wait()
}

func main() {
	mainMutex()
}
```

We use a `sync.waitGroup` as an elegant way to wait for both of the goroutines to finish executing, since goroutines don't have the traditional `.join()` facility available. I find this solution easier to read than using a separate "done" channel to coordinate termination of the main thread.

Golang's unbuffered channels, `theChannel` in this example, are perfect for this situation since both producers and consumers block until a value is put into or removed from the channel, respectively. This is why the for-loops on lines 17 and 27 don't immediately keep executing.

If `theChannel` was buffered with a size of one, the call to put a value into the channel wouldn't block on lines 20 and 28. This would cause the ping thread to potentially print "pong", which isn't what we want!

Running the example we see the desired output.

```bash
$ go run main.go
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
```

Golang also supports the traditional monitor-style synchronization primitives of mutexes and condition variables. Here's what the ping-pong problem looks like using that style of concurrency.

```golang {linenos=table}
// main.go
func mainMutex() {
	numTimes := 5
	var wg sync.WaitGroup
	m := sync.Mutex{}
	cv, printStr := sync.NewCond(&m), "ping"

	// Ping thread
	wg.Add(1)
	go func(n int) {
		defer wg.Done()
		for i := 0; i < n; i++ {
			cv.L.Lock()
			for printStr == "pong" {
				cv.Wait()
			}
			fmt.Println(printStr)
			printStr = "pong"
			cv.Signal()
			cv.L.Unlock()
		}
	}(numTimes)

	// Pong thread
	wg.Add(1)
	go func(n int) {
		defer wg.Done()
		for i := 0; i < n; i++ {
			cv.L.Lock()
			for printStr == "ping" {
				cv.Wait()
			}
			fmt.Println(printStr)
			printStr = "ping"
			cv.Signal()
			cv.L.Unlock()
		}
	}(numTimes)

	wg.Wait()
}

func main() {
	mainMutex()
}
```

Each thread waits its turn to print its designated `printStr`. They wait until the other thread signals that it's done with its turn by changing the `printStr` and by calling `cv.Signal()`. It's probably more correct to swap line 36 with 35 and line 20 with 19, but both orders work.

**Remember to always wrap your calls to `cv.Wait()` in a loop to handle spurious wakeups!**

Personally, I feel this style is less intuitive, but it's good to know it's still supported.

Running this example gives the same result.

```bash
$ go run main.go
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
```

Now let's take a look at the python implementation.

## Python

Python3 has a thread-safe queue [implementation](https://docs.python.org/3/library/queue.html), so we'll first look at an example that uses that. Python's queue differs slightly from an unbuffered Golang channel because producers do not block when enqueueing items, even if the queue has a max size of one (the default). This makes the default queue more like a buffered channel of size one in Golang.

This caveat forces us to use two separate queues so that one thread doesn't just print over and over, as was the case in the scenario we talked about with a buffered channel of size one in Golang.

Here is the code.

```python3 {linenos=table}
# ping_pong.py
import queue
import threading


def ping(ping_queue, pong_queue, num_times):
    for _ in range(num_times):
        print(ping_queue.get())
        pong_queue.put("pong")


def pong(ping_queue, pong_queue, num_times):
    for _ in range(num_times):
        ping_queue.put("ping")
        print(pong_queue.get())


if __name__ == '__main__':
    ping_queue = queue.Queue()
    pong_queue = queue.Queue()
    num_times = 5
    threads = [threading.Thread(target=ping, args=(ping_queue, pong_queue, num_times)),
               threading.Thread(target=pong, args=(ping_queue, pong_queue, num_times))]
    for thread in threads:
        thread.start()

    for thread in threads:
        thread.join()
```

By deafult, calls to `queue.get` will block until a value is availble, which is why lines 8 and 15 won't print until a value is enqueued.

This code produces the desired output.

```bash
$ python3 ping_pong.py
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
```

Python also supports monitor-style concurrency, but I figured it'd be more interesting to take a look at examples that use `asyncio` instead.

For a fantastic overview of the different concurrency options available in Python, as well as when to use each, check out [this article](https://realpython.com/python-concurrency/) from Real Python. Krondo's [article](http://krondo.com/in-which-we-begin-at-the-beginning/) on the different paradigms is also worth a read.

This problem isn't the most appropriate place to use `asyncio`, but life is short and can always use more asynchronous programming.

Here is the code.

```python3 {linenos=table}
# ping_pong_aio.py
import asyncio

async def ping(ping_event, pong_event, num_times):
    for _ in range(num_times):
        await ping_event.wait()
        print("ping")
        ping_event.clear()
        pong_event.set()

async def pong(ping_event, pong_event, num_times):
    for _ in range(num_times):
        ping_event.set()
        await pong_event.wait()
        print("pong")
        pong_event.clear()

async def main():
    ping_event, pong_event = asyncio.Event(), asyncio.Event()
    num_times = 5
    ping_task = asyncio.create_task(
        ping(ping_event, pong_event, num_times)
    )
    pong_task = asyncio.create_task(
        pong(ping_event, pong_event, num_times)
    )
    await ping_task
    await pong_task


if __name__ == '__main__':
    asyncio.run(main())
```

Here we use an `asyncio.Event` to have one task communicate to another (and to the event loop) that it is done with its turn. We use two different events to avoid confusion and prevent a task from signalling to itself that it's done, which wouldn't be very useful.

The ordering of the lines within the for-loops are to ensure that "ping" is printed first, just like in the other examples.

This example could modify a `print_str` variable where `print()` is called on lines 7 and 15, like in previous examples, but this approach works too so I figured I'd show it.

This code differs from the other examples thus far because it only runs in one thread! The lack of context switching is one of the main performance benefits of asynchronous models over purely threaded ones.

We see the same desired results from this code.

```bash
$ python3 ping_pong_aio.py
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
```

`asyncio` also has support for mutexes and condition variables (which combines the functionality of an [Event and a Lock](https://docs.python.org/3/library/asyncio-sync.html#asyncio.Condition)) for synchronization between tasks . I don't think these are used much in normal asynchronous programming, but we might as well see them in action.

Here is the `asyncio` code which uses `asyncio.Condition` instead of `asyncio.Event`

```python3 {linenos=table}
# ping_pong_aio.py
import asyncio

print_str = "ping"
async def ping_cond(cond, num_times):
    global print_str
    for _ in range(num_times):
        async with cond:
            while print_str != "ping":
                await cond.wait()
            print(print_str)
            print_str = "pong"
            cond.notify()

async def pong_cond(cond, num_times):
    global print_str
    for _ in range(num_times):
        async with cond:
            while print_str != "pong":
                await cond.wait()
            print(print_str)
            print_str = "ping"
            cond.notify()

async def main_cond():
    num_times = 5
    cond = asyncio.Condition()
    ping_task = asyncio.create_task(ping_cond(cond, num_times))
    pong_task = asyncio.create_task(pong_cond(cond, num_times))
    await ping_task
    await pong_task

if __name__ == '__main__':
    asyncio.run(main_cond())
```

The calls to `async with cond`, like on line 8, simply acquire the underlying mutex. Golang and Python's approach to have the condition variable be automatically associated with an underlying mutex is quite convenient, since this is regarded as best practices anyway.

`cond.notify()` simply alerts the other task that the `print_str` has been changed and that the current task's turn is over.

Once again we see the desired output from running this code.

```bash
$ python3 ping_pong_aio.py
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
```

Now let's take a look some examples in Rust.

## Rust

Rust also has native support for thread-safe queues for message-passing concurrency, which it also calls a channel, just like Golang. Unfortunately Rust's channels are only multiple-producer, **single-consumer** (abbreviated "mpsc") channels, which is somewhat limiting. It enforces only one consumer using Rust's innovative ownership semantics.

This differs from Golang's channels and Python's thread-safe queue, which are both multiple-producer, **multiple-consumer** (abbreviated "mpmc") channels/queues.

These concurrency primitives are much more flexible than Rust's, since many threads can take values out of the channel. It seems there are no plans to have a natively supported mpmc channel in Rust, at least based on this [GitHub issue](https://github.com/rust-lang/rfcs/issues/848).

To work around these limitations, we use two channels for each thread to send messages to the other. Here is the code.
```rust {linenos=table}
// src/main.rs
use std::sync::mpsc::{Sender, Receiver};
use std::sync::mpsc;
use std::sync::{Arc, Mutex, Condvar};
use std::thread;

fn main_channels() {
    let (ping_tx, ping_rx): (Sender<&str>, Receiver<&str>) = mpsc::channel();
    let (pong_tx, pong_rx): (Sender<&str>, Receiver<&str>) = mpsc::channel();
    let num_times = 5;

    let ping_thread = thread::spawn(move || {
        for _ in 0..num_times {
            println!("{:?}", ping_rx.recv().unwrap());
            pong_tx.send("pong").unwrap();
        }
    });
    let pong_thread = thread::spawn(move || {
        for _ in 0..num_times {
            ping_tx.send("ping").unwrap();
            println!("{:?}", pong_rx.recv().unwrap());
        }
    });
    ping_thread.join().unwrap();
    pong_thread.join().unwrap();

}

fn main() {
    main_channels();
}
```

As with most other primitives, the `_rx` ends of the channels block until a value can be removed, which causes the for-loops to wait until the other thread has had its turn.

I do like Rust's optional interface of passing a closure / lambda for a thread to run. It's always nice to save a few lines of code where possible (Golang and Python support this too).

This code also produces the desired result.

```bash
$ cargo run
   Compiling ping_pong v0.1.0 (/Users/Joey/Dev/sandbox/rust/ping_pong)
    Finished dev [unoptimized + debuginfo] target(s) in 0.92s
     Running `target/debug/ping_pong`
"ping"
"pong"
"ping"
"pong"
"ping"
"pong"
"ping"
"pong"
"ping"
"pong"
```

As with the other languages we've examined thus far, Rust also supports monitor-style concurrency. Rust's ownership model makes acquiring and releasing a mutex pretty fool-proof, mainly because there's no `unlock` function! Here is the code.

```rust
// src/main.rs
use std::sync::mpsc::{Sender, Receiver};
use std::sync::mpsc;
use std::sync::{Arc, Mutex, Condvar};
use std::thread;

fn main_mutex() {
    let num_times = 5;
    // let pair = Arc::new((Mutex::new(Some("ping")), Condvar::new()));
    let pair = Arc::new((Mutex::new("ping"), Condvar::new()));
    let pair2 = Arc::clone(&pair);
    let ping_thread = thread::spawn(move || {
        for _ in 0..num_times {
            let &(ref lock, ref cv) = &*pair2;
            let mut print_str = lock.lock().unwrap();
            while *print_str == "pong" {
                print_str = cv.wait(print_str).unwrap();

            }
            println!("{:?}", *print_str);
            *print_str = "pong";
            cv.notify_one();
        }
    });
    let pong_thread = thread::spawn(move || {
        for _ in 0..num_times {
            let &(ref lock, ref cv) = &*Arc::clone(&pair);
            let mut print_str = lock.lock().unwrap();
            while *print_str == "ping" {
                print_str = cv.wait(print_str).unwrap();

            }
            println!("{:?}", *print_str);
            *print_str = "ping";
            cv.notify_one();
        }
    });
    ping_thread.join().unwrap();
    pong_thread.join().unwrap();
}

fn main() {
    main_mutex();
}
```

This interface is really clunky to me, and certainly isn't intuitive to read! It's also way more lines the previous example which is not great. Clunky or not, it still produces the same result.

```bash
$ cargo run
   Compiling ping_pong v0.1.0 (/Users/Joey/Dev/sandbox/rust/ping_pong)
    Finished dev [unoptimized + debuginfo] target(s) in 0.92s
     Running `target/debug/ping_pong`
"ping"
"pong"
"ping"
"pong"
"ping"
"pong"
"ping"
"pong"
"ping"
"pong"
```

Let's take a look at how another systems language, C++, handles the task.

## C++

Unfortunately C++ doesn't have a native channel or thread-safe queue implementation. This means our only option provided by the STL is monitor-style concurrency.

Here is the code.

```cpp {linenos=table}
// Builds to executable ping_pong using CMake and Ninja, see source.
#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <chrono>

std::mutex mut;
std::condition_variable cv;
std::string print_str = "ping";

void ping(int n) {
    for (int i = 0; i < n; ++i) {
        std::unique_lock<std::mutex> lk(mut);
        while (print_str != "ping") {
            cv.wait(lk);
        }
        std::cout << print_str << "\n";
        print_str = "pong";
        lk.unlock();
        cv.notify_one();
    }
}

void pong(int n) {
    for (int i = 0; i < n; ++i) {
        std::unique_lock<std::mutex> lk(mut);
        while (print_str != "pong") {
            cv.wait(lk);
        }
        std::cout << print_str << "\n";
        print_str = "ping";
        lk.unlock();
        cv.notify_one();
    }
}

int main() {
    int n = 5;
    std::thread ping_thread(ping, n);
    std::thread pong_thread(pong, n);
    ping_thread.join();
    pong_thread.join();
}
```

Unsurprisingly, this code yields the same desired result.

```bash
$ ./ping_pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
```

## Conclusion

We examined a simple concurrency example in four languages, each looking fairly similar to the other. I found this to be useful exercise. It's not always the case that similar ideas yield similar code across languages, but this is definitely the case here.
