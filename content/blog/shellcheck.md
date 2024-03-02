---
title: "Use shellcheck!"
date: 2021-10-12
draft: false
categories: [shell]
author: Joey Buiteweg
---

[shellcheck](https://github.com/koalaman/shellcheck) is a super useful linter for your shell scripts.

I say shell scripts instead of `bash` scripts since you should typically avoid using bash to run your scripts, since `bash`:

- Includes functionality that isn't [POSIX](https://en.wikipedia.org/wiki/POSIX) compliant, which risks portability.
- Is slower than `dash`, which is POSIX compliant and includes no extra features.
- Has idiosyncracies, typically called bash-isms, that manage to creep their way into regular shellscripts

The above reasons are why you should put `#!/bin/sh` at the top of your scripts, and not `#!/bin/bash`. On Debian systems `/bin/sh` is symlinked to `/bin/dash` so that your scripts run as fast as possible. On other distros it might be linked to something else, but I highly recommend linking it to `dash`.

_Note: `/bin/sh` being linked to another shell is entirely different from your login shell. You can still use whatever login shell you want, I use `fish` for example, without it affecting your scripts. The scripts will still be invoked with a POSIX compliant shell._

Anyway. `shellcheck` helps you write POSIX compliant scripts, or will let you specify `#!/bin/bash` and use all the bash-isms you want. It also has detailed descriptions and justifications of its warnings on [their wiki](https://github.com/koalaman/shellcheck/wiki/Checks)

Writing shell scripts comes with a lot of footguns. `shellcheck` can help remove some of these, provided you heed its warnings!

```
 _________________
< Use shellcheck! >
 -----------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
```
