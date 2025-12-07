---
title: "Programming Languages"
date: 2025-12-07
draft: false
toc: true
categories: [rust, golang]
author: Joey Buiteweg
---
Mastery over a few languages helps people progress their careers faster. Switching your focus between many languages is like trying to hit a bullseye on a target that is constantly moving.

A PhD candidate who is always changing their dissertation topic is surely going to finish their program slower than someone who isn't. A software engineer at a large company who spends their precious free time learning Haskell instead of the languages that company uses is not likely to move up. I say this as having been that software engineer thus far in my career.

The following is a list of things to consider before deep diving into a new programming language. These factors lead companies to decide whether a programming language is worth their time or not. Outlining these considerations should show why Go and Rust have become popular recently.

# Tooling

## Build systems

Are there 11 different competing build systems out there? C, C++, JS/TS, and Python suffer in this department. Having to set up a build system for your project takes time and effort, especially as the project evolves.

Starting a new Rust project is just `cargo new`, `cargo build`. Go is just `go build`. No time spent reading `Meson`, `CMake`, `Buck`, or `Make` docs. No time spent fiddling with `yarn`, `npm`, `bun`, `deno`, or whatever flavor of the month tooling is out for JS/TS. No time spent fiddling with `pipenv`, `poetry`, `pyenv`. No time spent fiddling with gradle, maven or jars.

Build system speed matters too. For large projects, Go is fast. Rust is not, sadly, but is improving. For large projects, the Python and Javascript build systems I’ve used have been slow.

## Testing

Testing in Rust is just `cargo test`. In Go, it's `go test`.

No `cmocka`, `cpptest`, `pytest`, `jest`. Just one test runner that works well enough.

## Formatters

Formatting in Rust is just `cargo fmt`. In Go, it's `go fmt`.

While `rustfmt` [isn't perfect](https://github.com/rust-lang/rustfmt/issues/4306) it beats having to decide whether to use `prettier`, `eslint`, `black`, `yapf`,`autopep8`, 

A standardized formatter helps your team focus on semantics, rather than syntax.

## Debuggers

A good debugger that can pretty print goes a long way. Rust struggles here. `codelldb` and `rust-gdb` have a hard time printing useful info on `dyn` things. 

`delve` is good for Go and can chase pointers well. Any Go debugger will struggle with heavy amounts of nested `Context` objects though. Having to expand a `Context` involves recursively clicking all the `context.With` functions called on the original `Context`.

Python has one of the best debugging experiences I've seen. Being able to `import pdb` into your file and then `pdb.set_trace()` is so helpful. This isn't relevant for an IDE debugging experience but still useful.

Aside from a dedicated debugger, being able to print statement debug matters too. My recollection with Elm is that this [isn't straightforward](https://forkful.ai/en/elm/testing-and-debugging/printing-debug-output/).

`async` throws a wrinkle into debugging too. In `async` Rust, I can’t use “Step Over” when the debugger is on a line that calls `.await`. The workaround is to but a breakpoint after the line that does `.await`, but that gets old fast. I don’t find myself needing to do this in Go, since asynchrony is built into the runtime.

## Developer Environments

Languages like Java all but mandate the use of an IDE. Not all developers enjoy or feel productive in an IDE. Remote editing in an IDE is cumbersome, requiring plugins or remote filesystem mounting like `sshfs`. Languages that support a text editor well are simpler to develop on remotely.

Devcontainers are a solution to remote editing but are best suited to IDEs at the time of writing. But `neovim` does have [work in progress](https://github.com/esensar/nvim-dev-container) on this front.

The Language Server Protocol is an improvement in this landscape, but I’m not sure how well Java and friends like C# support it.

LSP lets developers use the editor they want. Rust and Go both have great LSP support.

# Developer Experience

## Joy

Joy is a relevant part of programming. It fights against burnout.

Mitchell Hashimoto is a great programmer, and sites joy as one of the reasons he chose Zig for Ghostty. Joy will help him and other contributors make the best version of Ghostty they can.

## Type Systems

I’ve found joy when a language helps me solve a problem succinctly and correctly, with confidence that the code I’ve written should stand the test of time.

A solid type system helps model programs correctly and eliminate  scenarios that are invalid, reducing the need for superficial unit tests surrounding type validation. It helps with error handling too.

I don’t find joy in writing

```go
func thing_that_could_error() (string, error) {
	a, err := do_io();
	if err != nil {
	    return "someFootGunValueYouCouldUse", err
	}
	return string(a), nil
}
```

If the writer of this function never intended for a value to be used when the error was returned, there is no way to express that in Go. This is unsettling.

In Rust
```rust
fn thing_that_could_error() -> Result<String, Box<dyn Error>> {
	let a = do_io()?;
	Ok(a.to_string())
}
```

You can’t misuse the result of `thing_that_could_error`. This is comforting.

These bits of error handling compound quickly in substantial programs. For Go, the code becomes overly verbose and slower to read. The slower the code is to read, the more complacent developers get in reading it, which is a problem when diligence is part of the error handling model like it is for Go and C.

C++ chooses opt-in safety when picking smart pointers, which is unsettling. In Rust, safety is opt-out, which is comforting.

Languages with `nil` and `null` present that as a footgun. Tony Hoare doesn’t call it the “billion-dollar mistake” for no reason. Go has `nil`, Rust does not.

## Application Safety

### Static Typing

Static types are good. The fact that most dynamically typed languages are now adding static types in the form of gradual tying corroborates that static types are good.

To me gradual typing is great for existing projects that want to catch more errors ahead of running tests. It helps avoid writing code like

```python
def my_func(thing)
	if type(thing) != str:
		return some_error()
		
	do_other_stuff()
```

Instead you get

```python
def my_func(thing: str):
	do_other_stuff()
```

Now I don’t need to write a unit test calling `my_func([])` checking the error output either!

Gradual typing is opt-in though. If the project is either misconfigured or too lenient, then you lost out on the safety.

Lenient gradual typing lets you do

```python
def my_func(thing: Any):
	do_other_stuff()
```

This is tempting when using a library to supply the arguments to my_func which does not have type annotations yet.

Instead if the language mandates static typing everywhere, this isn’t a problem. Rust and Go both have this advantage.

### Memory Safety

Security matters. Exploits are bad for business. Outages are bad for business.

Memory safety helps with both.

C is memory unsafe. C++ is opt-in memory safe. Rust, Python, JS, Java, and go are memory safe languages.



## Application Performance

### Design Choices
Performance matters. Casey Muratori has [argued](https://youtu.be/x2EOOJg8FkA) this better than I can. Watch that video, even if you disagree with it by the end it’s worth the watch.

Languages with different designs provide different performance. Designs choices include JIT, Garbage Collection, Reference Counting, Interpreted, Compiled.

Garbage collection has overhead. Reference counting has overhead but is much faster than pausing for garbage collection. Compiled languages are easier to optimize than interpreted languages, which is why they tend to be faster.

Go and Java have quick garbage collection, until they don’t. If your program finds a slow path in the garbage collection, it can be [costly to fix](https://www.evanjones.ca/jvm-mmap-pause-finding.html). 100ms-150ms of average time for garbage collector is a lot of latency. Hardware is fast, let’s use it well.

JIT can improve bytecode language performance, but sometimes it’s opt-in, like in python. `pypy` is fast but is [sometimes incompatible](https://dnmtechs.com/why-pypy-wasnt-included-in-standard-python/) with regular python.

### Concurrency Models

Computers do a lot of I/O.

Concurrency Models help us do I/O faster.

OS Threads combined with Synchronous I/O have more overhead, but are easier to program.

Async I/O and Green Threads have less overhead, but are harder to program. Making an async run-time is hard. Go and Rust have both done the hard work themselves, but Rust async is harder to program than Go.

Rust async compiler errors are harder to read. The types are more complicated. It will get better but there’s rough edges in 2025. As an aside, it looks like there’s finally a section in “The Rust Programming Language” book about `async` and the language types it relies on.

Go programs have async for free. The run-time lets you see I/O as I/O, async or sync is abstracted away.

I’m interested to see if [Zig’s goals](https://lwn.net/Articles/1046084/) for seamless async and sync I/O without function coloring can be achieved. (Pay for LWN if you can’t read that article, it’s worth it.)

Concurrency shines when paired with Parallelism. Functional Languages are cool - But getting safe, parallel execution is hard to incorporate into the runtime (they usually have a runtime/garbage collector). I’ve heard of PhD dissertations being a part of getting OCaml to have concurrency at all.

Async helps with I/O bound workloads, but for CPU bound workloads parallelism is paramount. Rust has `rayon` , Go has coroutines. Parallelism solutions are an important consideration.

Cooperative concurrency can be misused through blocking the executor, which prevents switching to other tasks. Preemptive concurrency with timer-based interrupts protects against blocking the program. `aysnc` rust is cooperative, I don’t think `tokio` leverages timer interrupts to provide preemption.

I’ll explain more about the taxonomy of Concurrency, Parallelism, Sync, Async, Stackful and Stackless coroutines in another blog post. It’s a complex topic.

## Developer Performance

How quickly a developer can write code matters. This is not the most important part of selecting a language though.

Plain Javascript and Python are unrivaled in coding speed. A small startup is prioritizing coding speed to get something working for the next round of investments. They similarly will deprioritize performance too.

However, these languages present far more technical debt out of the box than more modernized ones for previously outlined reasons.

A company looking to provide a quick exit for the most money with the bare minimum quality product might not care about that tech debt.

I prefer doing things the right way from the start. Pay the initial cost for consistent benefits in the future.

Feeling productive is not the same thing as being productive.

### Libraries

Another aspect of developer performance is availability of libraries and their maturity. If a language is newer, it’s less likely to have the libraries you need, and it’s less likely the libraries will be sufficiently battle tested.

Rust’s async web framework `axum` works well, but has rough edges. Doing simple things such as returning a specific error message when validating HTTP JSON bodies is hard, it includes the `serde` output. The compiler error messages are hard to sift through given the heavy usage of macros in the framework.

A language’s popularity also affects the availability of libraries. If less people and businesses are using that language, then fewer people are likely to interact with the niche you work in.

E.g: at the time of writing this is the most popular [QUIC library](https://github.com/shiguredo/quic-server-zig) in Zig, but states that is experimental and not for production use . Guess you’ll be forking this or writing your own implementation of QUIC in Zig! Conversely, [quic-go](https://github.com/quic-go/quic-go) looks ready to Go (pun intended).

Having libraries to do JSON de/serialization, base64 decoding, cryptography, network protocols, are vital to the success of a software project.

The language should preferably handle UTF-8 strings sanely by default. Null terminated strings that have no awareness of UTF-8 are not suited for higher level applications in this millenium.

### Interoperability with other Software

A key part of libraries is being able to interact with other commonly used pieces of software.

Do I have a library that works with Redis? MySQL? Those are mainstream pieces of software that you should have compatibility with.

[Temporal](https://temporal.io/ ) is the new hotness in durable execution, but it sadly has no Rust SDK or API client written in Rust. They are working on it though, since it’s been asked for. I doubt they are working on one for OCaml though.


## Foreign Function Interfaces

Being able to directly call code written in a different language, or allow another language to call code in the language you chose, is beneficial, even if it isn’t the most common operation for a particular domain.

Garbage Collected languages have difficulty with FFI. Go’s FFI experience through CGo is [cumbersome](https://dave.cheney.net/2016/01/18/cgo-is-not-go). It’s been awhile since I looked at this though, it may have gotten better since 2022.

Rust’s support for C FFI is great. Its support for C++ FFI is getting much better.

WASM is worth mentioning too. Being able to compile to WASM lets you run code in interesting places, like the Browser! Rust has good WASM support, it’s how `workers-rs` works (pun intended). I’ve never tried [WASM with Golang](https://go.dev/wiki/WebAssembly) but it looks like it exists.

Lua has this weird thing going for in that it’s easy to call from C code, so there’s that. You can call Lua plugins in Redis, Nginx, Neovim, Roblox, among others.

## Community Size and Support

The more popular a language is, the better suited it will be for someone who’s encountered the same issue as you. There will be more knowledgeable people to help you.

It makes a difference how easy it is to get help on complicated problems from experts inside and outside your company.

## Cryptography

If you want to sell products to U.S Government agencies, you’ll likely need to get Fedramp certified. This certification involves using FIPS approved crypto.

If you’re using a mainstream language, this process is well documented. In Rust it’s as simple as using aws-lc-rs with `ring`.

Golang’s built-in crypto libraries are excellent. But getting FIPS requires using BoringSSL with FIPS support, which is annoying but doable.


# Applicable Domains

Increasingly I’m seeing this matter less and less.

For Embedded Systems, there’s Micro Python, Tiny Go, Embedded Rust, plain old C. You wouldn’t think Python makes sense here but it works well for simple things.

For Web services, anything other than C is going to work fine.

`u-bmc` lets you run Go on your server’s BMC. Rust’s `nostd` lets you run it anywhere, even in the Linux Kernel! I could see Rust being used in UEFI firmware, but this is a bigger stretch with how much `unsafe` you’d have to use.

Point is, a popular language like Go can be used for many things beyond Micro Services.


# The End

Before you pick up another language, ask yourself, “Do I have extreme mastery of the languages I’m focused on?” Ask yourself about the considerations presented here.

I enjoyed learning Haskell. Doing Advent of Code problems in Haskell was fun. If doing that keeps you from burning out, that’s great.

But trying to master it is not useful for the avenues I’m trying to pursue in my career.

Learn new languages for fun if you want, but don’t expect your company to switch to them any time soon if they don’t satisfy the considerations mentioned here. If you’re not writing code in a language you want, look at switching companies if feasible.

# Another Consideration: The Shell

I agree wholeheartedly with the sentiment expressed in [this article](http://www.leancrew.com/all-this/2011/12/more-shell-less-egg/). The shell (`sh` or `bash`) is a better starting point than writing your own Apache Spark, but it does have a stopping point. Shell, i.e `sh`, is Turing Complete, which is wonderful, but it is not readable. 

I have seen Build Systems made of 1000s of lines of Shell. I have worked on and improved said Build Systems. Those improvements took a long time, because lots of Shell is hard to read.

If your Build System is made of 1000s of lines of shell, I would suggest moving it to a higher level language or a pre-made one like Bazel. That is all.
