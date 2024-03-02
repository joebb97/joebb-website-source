---
title: "A Curated List of Project Considerations"
date: 2020-11-28
draft: false
categories: [system-design]
author: Joey Buiteweg
---

# Project considerations

Above all else, it has to work.

System design hints. Elegant and simple design.

- Keep it [simple](https://en.wikipedia.org/wiki/Occam%27s_razor) ([stupid](https://en.wikipedia.org/wiki/KISS_principle)), don’t be Richard Hendricks from Silicon Valley trying to explain electrons to a user. Sometimes the strawman or brute force solution is good enough.

- Fail faster, build one design to throw it away, you arent going to get it right the first time. Google spends years getting things wrong too (it took them ~seven years to make [Google Spanner](https://www.youtube.com/watch?v=nvlt0dA7rsQ)).

- Avoid the [anti-patterns](https://en.wikipedia.org/wiki/Anti-pattern#Software_engineering).

- Narrow the waistband when many components connect to all other components. Create a common ground (e.g LLVM, Kafka, [LSP](https://en.wikipedia.org/wiki/Language_Server_Protocol), FIRRTL).

**Choose [boring technology](http://boringtechnology.club/) and choose fewer and simpler technologies with better known failure models**.

Research what the right tools (and protocols) are for the job.

- Research what's been done and what solutions have been made.

- Study what has worked and what hasn't worked.

- DON'T REINVENT THE [SQUARE WHEEL](https://en.wikipedia.org/wiki/Reinventing_the_wheel#Related_phrases). Avoid [NIH](https://en.wikipedia.org/wiki/Not_invented_here) syndrome.

- DON'T be an [architecture astronaut](https://www.joelonsoftware.com/2001/04/21/dont-let-architecture-astronauts-scare-you/), pick the proper technology to solve a problem, don't make up a problem just to use some technology.

Code style, quality and readability.

- Write good specifications and documentation (both for internal and external usage).

- Write good comments that describe WHY, not WHAT, you're doing. Imagine the person knows where you live that has to read it.

- Use style guides and linters.

- Good abstractions and separation of implementation.

- Maintainability and Serviceability. How easy is it to ship new features? What bogs you down?

- Keep it [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

Scalability.

Advocate for Devs and Customers, not one or the other. Helping improve one leads to helping the other.

- Explanation in [this video](https://www.youtube.com/watch?v=i69U0lvi89c).

UI/UX are very important, which i18n is a part of.

[Ship features](https://www.youtube.com/watch?v=o9pEzgHorH0), not code.

Exercise [good programming taste](https://www.ted.com/talks/linus_torvalds_the_mind_behind_linux).

Good, quality automated tests.

- Write tests while developing (TDD).

- Keep it [DAMP](https://testing.googleblog.com/2019/12/testing-on-toilet-tests-too-dry-make.html) (descriptive and meaningful phrases).

- CI/CD.

Automation.

- Spend time automating what is worth automating, not something you'll do once.

Instrumentation, logging, and monitoring are all crucial. Insight into what your system is doing is key. Don’t fly blind.

Easy, testable, reproducible, quick builds. Quick builds are essential for short iteration cycles.

Choose [micro services](https://microservices.io/patterns/microservices.html) ([if you need it](https://pythonspeed.com/articles/dont-need-kubernetes/)) and reasonable number of smaller implementations as opposed to one [monolith](https://microservices.io/patterns/monolithic.html).

Performance.

Correctness.

Fault-Tolerance and error handling, do the [end-to-end principle](https://web.mit.edu/Saltzer/www/publications/endtoend/endtoend.pdf) where appropriate.

Software development methods (choose [agile](https://www.atlassian.com/agile/manifesto))

Keeping track of bugs in a database.

SECURITY

- It’s a [mindset](https://www.sentinelone.com/blog/having-trouble-getting-senior-management-to-buy-in-to-your-security-recommendations-try-these-essential-tips/) not a feature. It’s not a destination that is ever reached unfortunately, it’s a journey that always has to be followed. Adopt the [security mindset](https://www.coursera.org/lecture/digital-democracy/the-security-mindset-sLtQu).

- Rational paranoia vs analysis paralysis.

You have to be [ethical](https://www.acm.org/code-of-ethics), professional, and excellent.

- Acknowledge the [Dunning-Kruger effect](https://en.wikipedia.org/wiki/Dunning%E2%80%93Kruger_effect), [four stages of competence](https://en.wikipedia.org/wiki/Four_stages_of_competence), and [Blub programmers](<https://en.wikipedia.org/wiki/Paul_Graham_(programmer)#Blub>).

Database for your equipment.

Licensing (gpl, mit, bsd, Creative Commons).

From [Bryan Cantrill](https://www.youtube.com/watch?v=30jNsCVLpAE), we should have a Bias towards observation, not rash actions.

- To debug, ask questions, **then** form a hypothesis.

Any of Joel Sposky's [various](https://www.joelonsoftware.com/2000/08/09/the-joel-test-12-steps-to-better-code/) [tips](https://www.joelonsoftware.com/2000/04/06/things-you-should-never-do-part-i/).
