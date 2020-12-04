---
title: "Butler Lampson's System Design Hints"
date: 2020-06-07
draft: false
categories: [system-design]
author: Joey Buiteweg
---

A summary of [Butler Lampson](https://en.wikipedia.org/wiki/Butler_Lampson)'s original [paper](https://bwlampson.site/33-Hints/Acrobat.pdf)

# 2 Functionality

## 2.1: Keep it simple

* Do one thing at a time, do it well. Make small, working, effective interfaces, they are contracts, don't try to do too much, don’t generalize.

* Get it right.

* Write specifications (then implement), document the abstract functionality provided by your application and its interfaces.

## 2.2: Corollaries

* Make it fast rather than general or powerful.

* Don’t hide the power of the interface, clients should know what it does well.

* Sometimes provide flexibility (allow the client to provide what they want to make it both general and powerful).

* Leave it to the client as long as it is cheap to pass control back and forth.

## 2.3: Continuity

* Keep basic interfaces stable, they are contracts. Legacy is sometimes unavoidable, but you can spoof it when needed.

* If you have to change interfaces, keep a place to stand, make sure stuff built on your old interface can still benefit from the new changes or even just work at all.

* Sometimes need to put old interface on top of a new system (easier than rewriting the whole thing, this is where VMs come in handy).

## 2.4: Making implementations work

* Plan to throw one away. Fail faster, you’re almost never going to get it right the first time (doesn’t mean you shouldn’t try).

* Keep secrets of the implementation (but don’t hide power), don’t allow clients to assume things they shouldn’t. The fewer assumptions the better when needing to port things, hard to design/re-design interfaces.

* Sometimes can benefit from adding more assumptions, but a balance is needed

* Divide and conquer functionality.
    * Reduce a hard problem into several smaller ones.
    * Solve those smaller problems with effective interfaces and abstractions.
    * Divide resources or limit them depending on what gives better output.
    * Defer and avoid work or just substitute work for other things.

* Use a good idea again instead of generalizing. Sometimes the specific implementation is better than trying to make that implementation work everywhere.

## 2.5: Handling all the cases

* Handle the normal and worst cases separately, the requirements are very different.
    * Optimizing the tail is different from optimizing normal execution.
    * The normal case must be fast, the worst case must make some progress.

# 3 Speed

* Split resources in a fixed way if in doubt, rather than sharing them. Allocator can be predictable, use registers instead of memory.

* Use static analysis if you can, don’t delude with bad one.

* Dynamic translation (Do expensive translation to faster context once, benefit overall).

* Cache answers to expensive computations rather than doing them over. Don’t want to thrash though, need to be able to fit all active values.

* Use hints to speed up normal execution. Hints can be wrong and might not result from an associated lookup. Need to be able to check its correctness. Check it against truth, supposed to make things run fast (must be correct nearly all the time). Routing sometimes uses this (BGP does)

* When in doubt, use brute force, straightforward easily analyzed solution w/ special purpose computing is better than complex, poorly characterized one that only works well if some assumptions are satisfied.

* Asymptotically faster algorithm is not necessarily better. Sometimes the dumb brute force thing just works better and is easier to deal with.

* Compute in the background when possible (defer work or do it when nobody is looking). Use the time allotted to you (consolidate things overnight).

* Use batch processing. Do jobs in groups, normally the cost of starting each job individually plus doing the job outweighs the cost of doing them all at once. (Bank does all their computation jobs at once overnight).

* Safety first, avoid disaster when allocating resources, don’t try to always be optimal.
    * Overloading a system can drastically degrade its service. Leave head room for things if you can, don’t cause thrashing.
    * Cleverness only really works if you know the load. CPU scheduling example, be lazy and safe some times

* Shed load to control demand, rather than allowing the system to become overloaded. 
    * Like how mac’s intentionally run a process that does empty CPU operations to cool it down.
    * Drop packets as a router if it’s flooded, memory manager limits jobs.
    * Worst case the system crashes and can start over with less load.
    * Arpanet tried to always deliver a packet, but this lead to deadlocks a lot if a link goes down.

# 4 Fault-tolerance

* End-to-end, Error recovery at application level is required for reliable system. HANDLE YOUR EXCEPTIONS CORRECTLY! Idempotency matters here.
    * Check the end-to-end errors, add intermediate checks if errors are super frequent.
    * Routers again drop packets if something went wrong or notify the sender.
    * Need cheap test for success, also might not see issues until heavy load

* Log updates to record the truth about the state of an object.
    * Log based file system is an example. Similar to record and replay debugging.
    * HAS TO BE IDEMPOTENT THOUGH in case you end up applying the same operation twice.
    * Store versions of an object and make those versions immutable (like in Clojure and other functional programming languages).

* Make actions atomic or restartable (transactions that complete or do nothing).
    * Commit records in databases, an operation should either happen in its entirety or not at all.
    * Again need a restartable operation (idempotent)

* Replicate state across nodes (distributed systems).
