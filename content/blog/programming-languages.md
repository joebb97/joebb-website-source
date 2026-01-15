---
title: "Programming Languages"
date: 2025-12-07
draft: false
toc: true
categories: [rust, golang]
author: Joey Buiteweg
---
Mastery over a few languages helps progress careers faster. Switching your focus between many languages is like trying to hit a bullseye on a target that is constantly moving.

The following is a list of things to consider before deep diving into a new programming language. These factors lead companies to decide whether a programming language is worth their time or not. Outlining these considerations should show why Go and Rust have become popular recently.

# Tooling

## Build systems

Are there 11 different competing build systems for the language? C, C++, JS/TS, and Python suffer in this department. Having to set up a build system for your project takes time and effort, especially as the project evolves.

Starting a new Rust project is just `cargo new`, `cargo build`. Go is just `go build`. No time spent reading `Meson`, `CMake`, `Buck`, or `Make` docs. No time spent fiddling with `yarn`, `npm`, `bun`, `deno`, or whatever flavor of the month tooling is out for JS/TS. No time spent fiddling with `pipenv`, `poetry`, `pyenv`, `uv`. No time spent fiddling with `gradle`, `maven` or `jars`.

Build system speed matters too. For large projects, Go is fast. Rust is not, sadly, but is improving. For large projects, the Python and Javascript build systems I’ve used have been slow.

## Testing

Testing in Rust is just `cargo test`. In Go, it's `go test`.

No `cmocka`, `cpptest`, `catch2`, `googletest`, `pytest`, `jest`. Just one test runner that works well enough.

In fairness, Rust has a small divergence with `cargo nextest`. But using it requires changes in CLI invocation only, not your test code. It’s merely a better test runner with more features.

## Formatters

Formatting in Rust is just `cargo fmt`. In Go, it's `go fmt`.

While `rustfmt` [isn't perfect](https://github.com/rust-lang/rustfmt/issues/4306), it beats having to decide whether to use `prettier`, `eslint`, `black`, `yapf`,`autopep8`, and it beats having to set up yet another dependency locally and in CI.

A standardized formatter helps your team focus on semantics rather than syntax.

## Debuggers

A good debugger that can pretty print goes a long way. Rust struggles here. `codelldb` and `rust-gdb` have a hard time printing useful info on `dyn` things. 

`delve` is good for Go and can chase pointers well. Any Go debugger will struggle with heavy amounts of nested `Context` objects though. Having to expand a `Context` involves recursively clicking all the `context.With` functions called on the original `Context`.

Python has one of the best debugging experiences I've seen. Being able to `import pdb` into your file and then `pdb.set_trace()` is so helpful.

Aside from a dedicated debugger, being able to `printf()` debug matters too. My recollection with Elm is that this [requires weird syntax](https://forkful.ai/en/elm/testing-and-debugging/printing-debug-output/).

`async` throws a wrinkle into debugging too. In `async` Rust, I can’t use “Step Over” when the debugger is on a line that calls `.await`. The workaround is to put a breakpoint after the line that does `.await`, then “Continue”, but that gets old fast. I don’t find myself needing to do this in Go.

## Developer Environments

Languages like Java all but mandate the use of an IDE. Not all developers enjoy or feel productive in an IDE. Remote editing in an IDE is cumbersome, requiring plugins or remote filesystem mounting like `sshfs`. Languages that support a text editor well are simpler to develop on remotely.

Devcontainers provide a nice portable dev environment, but are best suited to IDEs at the time of writing. But `neovim` does have [work in progress](https://github.com/esensar/nvim-dev-container) on this front.

The Language Server Protocol (LSP) is an improvement in this IDE confined landscape, but I’m not sure how well Java and friends like C# support it.

LSP lets developers use the editor they want. Rust and Go both have great LSP support. rust-analyzer uses a lot of memory though, which I hope improves.

# Developer Experience

## Joy

Joy is a relevant part of programming. It fights against burnout.

Mitchell Hashimoto is a great programmer, and he sites his enjoyment as one of the reasons he chose Zig for Ghostty. Joy will help him and other contributors make the best version of Ghostty they can.

## Type Systems

I’ve found joy when a language helps me solve a problem succinctly and correctly, with confidence that the code I’ve written should stand the test of time.

A solid type system helps model programs correctly and eliminate  scenarios that are invalid, reducing the need for superficial unit tests surrounding type validation. It helps with error handling too.

I don’t find joy in writing

```go
func thing_that_could_error() (string, error) {
	a, err := do_io();
	if err != nil {
	    return "", err
	}
	return string(a), nil
}
```

If the writer of this function never intended for a value to be used when the error was returned, then there is no way to express that in Go. This is unsettling.

In Rust
```rust
fn thing_that_could_error() -> Result<String, Box<dyn Error>> {
	let a = do_io()?;
	Ok(a.to_string())
}
```

You can’t misuse the result of `thing_that_could_error`. You have to panic with `unwrap`/`expect`, bubble up the error, or provide a sufficient default. This is comforting.

These bits of error handling compound quickly in substantial programs. For Go, the `if err != nil`s become overly verbose and slower to read. The slower the code is to read, the more complacent developers get in reading it, which is a problem when diligence is part of the error handling model like it is for Go and C.

Errors as values, which Go and Rust both do, are much better than Exceptions. Exceptions require inspecting function documentation to know if a function will throw an exception or not. Errors which are values present themselves in the function signatures automatically! Google’s style guide for C++ notably bans Exceptions for other [good reasons](https://google.github.io/styleguide/cppguide.html#Exceptions).

Languages with `nil` and `null` present that as a footgun. Tony Hoare doesn’t call it the “billion-dollar mistake” for no reason. Go has `nil`, Rust does not.

### Sum Types

Sum types like `enum` in Rust are awesome. In C, C++, and Go an enum is just a number, which severely limits how we can represent data in types.

## Application Safety

### Static Typing

Static types are good. The fact that most dynamically typed languages are now adding static types in the form of gradual typing corroborates that static types are good.

Gradual typing is great for existing projects that want to catch more errors ahead of running tests. It helps avoid writing code like

```python
def my_func(thing):
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

Gradual typing is opt-in though. If the project is either misconfigured or too lenient, then you lose out on the safety.

Lenient gradual typing lets you do

```python
def my_func(thing: Any):
	do_other_stuff()
```

This is tempting when using a library to supply the arguments to my_func which does not have type annotations yet.

Instead if the language mandates static typing everywhere, this isn’t a problem. Rust and Go both have this advantage.

Type inference makes static typing less verbose. It’s why C++ and Rust have `auto` and `let`, respectively. People used to have qualms with typing out long types in Java, which is no longer an issue in newer statically type languages.

### Memory Safety

Security matters. Exploits are bad for business. Outages are bad for business.

Memory safety helps with both.

C is memory unsafe. C++ has opt-in safety in that smart pointers are not mandated by the compiler, which is unsettling. In Rust, pointer safety is opt-out, which is comforting. Rust, Python, JS, Java, and Go are memory safe languages.

Memory unsafe languages require extensive fuzzing to be sure they are being used safely, which requires time and effort.

## Application Performance

### Design Choices
Performance matters. Casey Muratori has [argued](https://youtu.be/x2EOOJg8FkA) this better than I can. Watch that video, even if you disagree with it by the end it’s worth the watch.

Languages with different designs provide different performance. Designs choices include JIT, Garbage Collection, Reference Counting, Interpreted, Compiled.

Garbage collection has overhead. Reference counting has overhead but is much faster than pausing for garbage collection. Compiled languages are easier to optimize than interpreted languages, which is why they tend to be faster on the CPU.

Go and Java have quick garbage collection, until they don’t. If your program finds a slow path in the garbage collection, it can be [costly to fix](https://www.evanjones.ca/jvm-mmap-pause-finding.html). 100ms-150ms of average time for garbage collector is a lot of latency. Hardware is fast, let’s use it well.

JIT can improve bytecode language performance, but sometimes it’s opt-in, like in Python. `pypy` is fast but is [sometimes incompatible](https://dnmtechs.com/why-pypy-wasnt-included-in-standard-python/) with regular python. Looks like regular Python (CPython) is looking at [implementing JIT](https://peps.python.org/pep-0744/).

Languages that let you decide how much cost to incur from features are great. Rust with its “Zero cost abstractions” and other languages with a minimal runtime or no garbage collection shine here. Rust and C++ let you skip dynamic dispatch with generics, whereas Go did not support generics until recently. Go’s generics support is clunky and limited though. If you want to do SIMD, Rust has good support for this through [intrinsics](https://doc.rust-lang.org/std/intrinsics/simd/index.html).

Languages without garbage collection let you control your allocations closely. With `nostd` you can write Rust code for environments that don’t even have an OS allocator available.

### Concurrency Models

Computers do a lot of I/O.

Concurrency Models help us do more while waiting on I/O.

OS Threads combined with Synchronous I/O have more overhead, but are easier to program.

Async I/O and Green Threads have less overhead, but are harder to program. Making an async runtime is hard. Go and Rust have both done the hard work themselves, but async Rust is harder to program than Go.

async Rust compiler errors are harder to read. The types and function signatures are more complicated. That will get better, but there’s rough edges in 2025. As an aside, it looks like there’s finally a [section](https://doc.rust-lang.org/book/ch17-00-async-await.html) in “The Rust Programming Language” book about `async` and the language types it relies on. This was not the case for a number of years after `async` was added to the language.

Go programs have async for free. The run-time lets you see I/O as I/O, async or sync is abstracted away.

I’m interested to see if [Zig’s goals](https://lwn.net/Articles/1046084/) for seamless async and sync I/O without function coloring can be achieved. (Pay for LWN if you can’t read that article, it’s worth it.)

Concurrency shines when paired with Parallelism. Functional Languages are cool - But getting safe, parallel execution is hard to incorporate into the runtime (they usually have a runtime/garbage collector). I’ve heard of PhD dissertations being a part of getting OCaml to have concurrency at all.

Async helps with I/O bound workloads, but for CPU bound workloads parallelism is paramount. Rust has `rayon` , Go has goroutines. Parallelism solutions are an important consideration.

Cooperative concurrency can be misused through blocking the executor, which prevents switching to other tasks. Preemptive concurrency with timer-based interrupts protects against blocking the program. `aysnc` rust is cooperative, I don’t think `tokio` leverages timer interrupts to provide preemption. Go’s concurrency is preemptive.

I’ll explain more about the taxonomy of Concurrency, Parallelism, Sync, Async, Stackful and Stackless coroutines in another blog post. It’s a complex topic.

## Developer Performance

How quickly a developer can write code matters. This is not the most important part of selecting a language though.

Plain Javascript and Python are unrivaled in coding speed. A small startup will prioritize coding speed to get something working for the next round of investments. They similarly will deprioritize performance too.

However, these languages present far more technical debt out of the box than more modern ones for previously outlined reasons.

A company looking to provide a quick exit for the most money with the bare minimum quality product might not care about that tech debt.

I prefer doing things the right way from the start. Pay the initial cost for consistent benefits in the future.

### Libraries

Another aspect of developer performance is availability of libraries and their maturity. If a language is newer, it’s less likely to have the libraries you need, and it’s less likely the libraries will be sufficiently battle tested.

Rust’s async web framework `axum` works well, but has rough edges. Doing simple things such as returning a specific error message when validating HTTP JSON bodies is hard, it includes the `serde` output. The compiler error messages are hard to sift through given the heavy usage of macros in the framework.

A language’s popularity affects the availability of libraries. If less people and businesses are using that language, then fewer people are likely to interact with the niche you work in.

For example, at the time of writing, this is the most popular [QUIC library](https://github.com/shiguredo/quic-server-zig) in Zig, but states that it’s experimental and not for production use . Guess you’ll be forking this or writing your own implementation of QUIC in Zig! Conversely, [quic-go](https://github.com/quic-go/quic-go) looks ready to Go (pun intended).

Having libraries to do JSON de/serialization, base64 decoding, cryptography, network protocols, are vital to the success of a software project. The Go standard library is excellent. It has many useful libraries out of the box and is my favorite part of the language.

The language should handle UTF-8 strings sanely by default. Null terminated C-strings that have no awareness of UTF-8 are not suited for higher level applications in this millennium. Go and Rust both handle UTF-8 sanely by default.

### Interoperability with other Software

A key part of libraries is being able to interact with other commonly used pieces of software.

Do I have a library that works with Redis? MySQL? Those are mainstream pieces of software that you should have compatibility with.

[Temporal](https://temporal.io/ ) is the new hotness in durable execution, but it sadly has no Rust SDK or API client written in Rust. They are working on it though, since it’s been asked for. I doubt they are working on one for OCaml though.


## Foreign Function Interfaces

Being able to directly call code written in a different language, or allow another language to call code in the language you chose, is beneficial, even if it isn’t the most common operation for a particular domain.

Garbage Collected languages have difficulty with FFI. Go’s FFI experience through CGo is [cumbersome](https://dave.cheney.net/2016/01/18/cgo-is-not-go). It’s been awhile since I looked at this though, it may have gotten better since 2022 when I last encountered it.

Rust’s support for C FFI is great. Its support for C++ FFI is getting much better.

WASM is worth mentioning too. Being able to compile to WASM lets you run code in interesting places, like the Browser! Rust has good WASM support, it’s how `workers-rs` works (pun intended). I’ve never tried [WASM with Golang](https://go.dev/wiki/WebAssembly) but it looks like it exists.

Lua has this weird quirk in that it’s easy to call from C code. That’s why you can write Lua plugins for Redis, Nginx, Neovim, Roblox, among others.

## Community Size and Support

The more popular a language is, the better suited it will be for someone who’s encountered the same issue as you. There will be more knowledgeable people to help you.

It makes a difference how easy it is to get help on complicated problems from experts inside and outside your company.

## Cryptography

If you want to sell products to U.S Government agencies, you’ll likely need to get FedRAMP certified. This certification involves using FIPS approved crypto.

If you’re using a mainstream language, this process is well documented. In Rust it’s as simple as using aws-lc-rs as a replacement for `ring`.

Golang’s built-in crypto libraries are excellent. But getting FIPS requires using BoringSSL with FIPS support, which is annoying but doable.

# Applicable Domains

Increasingly I’m seeing this matter less and less.

For Embedded Systems, there’s MicroPython, TinyGo, Embedded Rust, and plain old C. You wouldn’t think Python makes sense here, but it works well for simple things.

For Web services, anything other than C is going to work good enough in that domain.

`u-bmc` lets you run Go on your server’s BMC. Rust’s `nostd` lets you run it anywhere, even in the Linux kernel! There is official Linux kernel code written in Rust. The `oreboot` (a Rust fork of `coreboot`) project shows Rust can be used in firmware too. C is not the only option in these more niche low-level systems programming domains.

The point is, a popular language can be used beyond the common domain you see it used. Go can be used for many things beyond micro services. Rust can be used for things beyond systems programming, like [web services](https://blog.adamchalmers.com/why-rust-on-backend/). Python can be used for things beyond scripting.

Given that popular languages can be used for anything, it follows that we should go for the languages that score well on the other categories detailed in this writing.

# Another Consideration: The Shell

I agree wholeheartedly with the sentiment expressed in [this article](http://www.leancrew.com/all-this/2011/12/more-shell-less-egg/), which advocates for re-using existing `coreutils` programs for small tasks. But for large tasks, the shell is woefully unwieldy.

I have seen Build Systems made of 1000s of lines of Shell. I have worked on and improved said Build Systems. Those improvements took a long time, because lots of Shell is hard to read.

If your Build System is made of 1000s of lines of shell, I would suggest moving it to a higher level language, or a pre-made build system like Bazel.

Feel free to open an issue or discussion Github if you want to talk about this blog post in the open, or feel free to message me for offline discussion. Thanks for reading!

# My ideal programming language

My ideal language would be `sync` Rust with Go’s transparent `async` runtime in which there are no colored functions.

This is somewhat feasible with a stackful coroutine library in Rust like [may](https://github.com/Xudong-Huang/may), but it requires using special `may` specific concurrency types like Thread, Mutex, and Cv. `may` isn’t the default in the language like how `goroutines` and `channels` are.

At one point Rust was pursuing stackful coroutines (also called green threads) but [abandoned it](https://github.com/rust-lang/rfcs/blob/master/text/0230-remove-runtime.md) so that the language itself didn’t require a large runtime. Instead they chose stackless coroutines (Futures) at the core of the language, with the runtimes provided in libraries, like `tokio`. For the design goals of Rust I think this was the right decision, it’s just not what I find the most enjoyable.

# The End

Before you pick up another language, ask yourself, “Do I have extreme mastery of the languages I’m focused on?” Ask yourself about the considerations presented here.

I enjoyed learning Haskell. Doing Advent of Code problems in Haskell was fun. If doing that keeps you from burning out, that’s great.

But trying to master it is not useful for the avenues I’m trying to pursue in my career.

Learn new languages for fun if you want, but don’t expect your company to switch to them any time soon if they don’t satisfy the considerations mentioned here. If you’re not writing code in a language you want, look at switching companies if feasible.
