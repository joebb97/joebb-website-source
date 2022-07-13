---
title: "Languages. Mainly those used for programming."
author: Joey
date: 2022-07-05
draft: false
categories: [rant]
---

## {{< rawhtml >}}<div style="color:red">Warning: Runaway Train of Thought Ahead{{< /rawhtml >}}
I agree wholeheartedly with the sentiment expressed in [this article](http://www.leancrew.com/all-this/2011/12/more-shell-less-egg/). The sentiment expressed there - that shell is a better starting point than writing your own Apache Spark - is good, but it does have a stopping point. Shell, i.e `sh`, is Turing Complete, which is wonderful, but it is not entirely readable. 

I have seen Build Systems made of 100s upon 100s of lines of Shell. I have worked on and improved said Build Systems. But in the process the amount of blood extruded from my eyeballs was at an all time high.

Hence why we should look to languages that scale better for more people. People from a diverse set of backgrounds. Which led me to thinking about our options for languages that run this world of ours. Which led me to the ensuing rant.

## Some poetry about Assembly Languages
```
I. Am. That I Am.

    I = {x86, CISC},
    "CISC" == Complex Instruction Set Computer

That. I = {x86, CISC}. Am. is hard for humans.
{amd64, x86}               is hard for humans.

  Yes. amd64 == x86_64. Fun fact.
  In general, amd64 == x86. History!

ARM (Advanced RISC Machine) is easier, but still hard, for humans,

  "RISC" == Reduced Instruction Set Computer.
  Yes. That's what ARM stands for. Fun Fact.
```

---

## But for real

Assembly is a necessary evil.
Sometimes a compiler is too much obfuscation surrounding the bits flowing where they flow.
They flow over [busses](https://en.wikipedia.org/wiki/Bus_(computing)), over wires with [serial protocols. I get it. But!

I am a human. And I avoid reading and writing assembly - even though I can - when I can because. Well. 
I am not a spineless, brainless piece of silicon. I breathe Oxygen, not Electrons! A CPU doesn't think.

It does math = `{add, sub, mul, div}`, and logic = `{branch, compare, jump}` instructions billions of times a second, hence the whole GHz thing.

The Instruction Set Architecture defines what the computer / CPU does,
and it is represented in an Assembly Language for human beings.
Each instruction gets turned into `$(bitWidth)` number of 0s and 1s in the executable (called the binary) by the Assembler (`/usr/bin/as` on  macOS).
This distance between what the CPU understands and what the human understands is too small here. It's why

```s
square(int):
        push    rbp
        mov     rbp, rsp
        mov     DWORD PTR [rbp-4], edi
        mov     eax, DWORD PTR [rbp-4]
        imul    eax, eax
        pop     rbp
        ret
```

makes a lot less sense at a glance than

```c
int square(int num) {
    return num * num;
}
```

(see [godbolt](https://godbolt.org/))


There is no equating our brains and our intelligence with that poopy-doodoo robot brain called
{ siri, alexa, google voice assistant }. That is, total nonsense!

Here's what should probably happen when we develop the software that runs the world.

## A Monospaced Font Demonstration of the Futility of my Thoughts (l-o-l)

```
START:
DO:
    while(bad code || sad || unproductive) {
SIMPLE: write POSIX shell, KISS, use simple plaintext, use awk!
        if (SIMPLE doesn't work) {
           write in pseudocode, then write it yourself
           if (sufficient) {
             continue
           }
           // otherwise,
           write in a real ding-danging PL // A good one! [1]
        }
    }
END:

/* [1] A real academic, robust, "enterprise ready" programming language.
* There are many to choose from. But they are *not*. **NOT**.
* ABSOLUTELY NOT { 
    python{
      2, 2.7. 3.3, 3.7. 3.9, /etc.
    }
    (notReallyJava)Script <- a.k.a "what even is scoping script",
    TypeScript,
    Ruby
 }
* I say these languages aren't "enterprise ready" because.
* They were not designed. Adequately.
* For the problems we try to apply them to, such as {
    banking,
    ecommerce,
    social media,
    military,
    embedded devices (
        like Belkin's worthless 'digital light switches!
        it should just be an analog light switch. not a computer.
        change my mind. you probably won't
    ), // End most embedded devices.
       // I've seen their guts. I know their guts. It's bad fam.
    Smart TVs (
        seriously most of these things are giant pieces of garbage.
        Because, well. 
        I'm gonna guess there's some really unperformant
        interpreted [i.e slower, that is a fact, not an opinion],
            {dynamic, duck, weakly}-typed langs in there.
    ) // end SMART TVs
* } // end "for the problems"
} // end ABSOLUTELY NOT
* 
* INSTEAD. I say the languages we should lean towards are:
*    - Compiled.
*    - Strongly Typed.
*    - (Sometimes, but not required) Statically Typed.
*    - Safe by default. Footguns are opt-in, not opt-out.
*    - (Sometimes, depending on the domain) Light on syntax.
*    - Mostly performant out of the box.
*       > You normally get this by just having a flapping compiler
          and the decades of research that comes with one.
          Blessed be thy LLVM and WASM.
*    - Well researched. Well designed.
        > they have means of reducing boilerplate. like generics.
          error propagation, etc.
*    - Can do any I/O. Lol. Simon Peyton-Jones said in a talk that Haskell
       used to struggle with this at one point. No longer!
       It has I/O, concurrency, async, and it's all pretty great!
*
* Some that I've come across that fit this bill:
*    - Rust
*    - Elm
*    - Haskell
*    - OCaml
*    - Elixir 
*    - Scala'
*    - Julia'
* ': I haven't dealt with these, but I've heard good things.
*/
```

That list I just rattled off is by no means exhaustive.
But `golang` is **very intentionally** left off of the list.
Because of how I write
```golang
if err != nil {
    return "someFootGunValueYouCouldUse", err
}
```
every other line, which means it violates the points, _well researched and well designed_, and _safe by default_.

Java is incredibly verbose. C is unsafe. C++ is opt-in safety, meaning it depends upon your own dutifulness.

[Node](https://nodejs.org/en/) is a thing, paired with TypeScript it gives a huge ecosystem and tons of prior work. Heck [Joyent](https://www.joyent.com/) even built an entire Public Cloud with it!!! It was necessary at that point in history (2009 says wikipedia). I think if we're starting fresh though, we can ask more of our infrastructure languages.

The field of PL research (whose papers I absolutely have not read btw) has come a loooong way since those grey beards concocted a kernel worth two shits at Bell Labs. Called UNIX. With the forward slashes and what not. 

Most of the research has yielded a loooot of niceties. Such as enums that are really enums (sum types I believe they're called) and not just a silly increasing number. Lookin' at you **Golang and C++**. Rust has enums that can each carry their own data, that way you don't accidentally use the wrong data.

And of course they have composition / structures / product types (I think is what they're called). But python sure as shit didn't until 3.7 when it added `datatype`.

Just. Ask more of your languages. Especially if you are going to be using them. Every. Single. Day of the week and for most projects at your {research lab, computer company, poopy web service}. Stop defensive programming with lines of code like

```c
if (thingy != nil && typeof thingy == typeIWantThingyToBe) {
    // Oh thank effing god now I can actually use thingy without
    // worrying about this Stinger missle imploding.
    // Since it could be there's some proprietary garbage
    // language without type safety running in a Stinger missle
    // for all we know
}
```

or re-enacting the following scenario

1. Write some code like
```python
def a_function_without_types(thingy):
    pass # on this language as a whole
```
2. Then. 200 years later. You find your code not working because something has
magically changed types while your program was running because, well, your ish is duck-typed.
And now you have to, for about 5000+ lines of code, add in mind-numbing annotations like
```python
def a_function_without_types_but_now_has_them(thingy: thingyType):
    # but the type checking doesn't actually matter until you add
    # something to your project to make sure it's being done.
    # because eff me right?
    # So it's still totally possible for you to submit programs
    # to the "compiler" MyPy and just ignore its errors, which once
    # again brings you back to unsafe by default.

    pass # on this language as a whole
```
3. Wish you'd picked a language with a compiler because that's what CS
research has pointed us to probably since the Unix Epoch.

## Complaints I already know about

* It's too verbose!
    - Not if it's got type inference 👍🏼. Yay type inference and patterns like
    ```rust
    let x = "dingdong";
    // do things with x
    let x = Ditch();
    // do more things with x
    ```
    And if that's too verbose for ya, those other languages I listed have fairly light syntaxes or means of making syntax light.
* Inheritance sucks!
    - Yes it does! None of the languages I recommended above make you practice that
    trash pattern from the late 90s. Some don't even support it whatsoever!
    - Composition/structures are me and [Jon Gjengsent](https://rust-for-rustaceans.com/)'s spirit animals.
    Dynamic dispatch is nice and also achievable without. Shitty. Inheritance that looks something like
      - `Handler -> WebHandler -> ApiHandler -> ApiV2Handler -> ThingThatAlmostDoesHTTP -> ThingThatActuallyDoesHTTP`
    and it juuust gets worse from there.
* Those languages have no package ecosystem!
    - They actually do. It's just not as massive as the `npm` ecosystem. Also the `npm` ecosystem has a [myriad](https://www.theregister.com/2016/03/23/npm_left_pad_chaos/) of [issues](https://www.bleepingcomputer.com/news/security/dev-corrupts-npm-libs-colors-and-faker-breaking-thousands-of-apps/)
