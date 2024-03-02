---
title: "A Consolidated List of Bad Computer Security Things"
date: 2020-11-27
draft: false
toc: true
categories: [security]
author: Joey Buiteweg
---

Things that are bad, dumb, or broken (security checklist), in a few categories.
If you see one of these acronyms or ideas somewhere in your code or product then that's no good.

## In Cryptography

- MD5

- SHA1

- Mac then Encrypt (should be Encrypt then Mac), or really should just be GCM / AEAD

- AES-\*-EBC, AES-\*-CBC or anything that isn't GCM or AEAD

- Snake oil crypto

- Padding oracles

- [Bleinchenbacher attack](https://en.wikipedia.org/wiki/Adaptive_chosen-ciphertext_attack#Practical_attacks)

- Reusing symmetric keys (block or stream ciphers)

- DES, RC4

- Hashing is not encryption

- Hashing without a shared secret for MAC (length extension attacks)

- PGP ecosystem and the web of trust

  - Based on [opinions](https://latacora.micro.blog/2019/07/16/the-pgp-problem.html) from
    [people](https://blog.filippo.io/giving-up-on-long-term-pgp/) much [smarter](https://blog.cryptographyengineering.com/2014/08/13/whats-matter-with-pgp/) than me

- [WEP](https://en.wikipedia.org/wiki/Wired_Equivalent_Privacy#Weak_security)

## In TLS

- DHE_EXPORT and other export grade crypto

- DH-512, RSA-512 or anything lower than 3072 bit asymmetric keys

- Things that aren't ECDHE w/Ed25519

- Reusing primes for DH key exchange

- Using weak primes for DH key exchange

- NIST CURVES from the NSA or curves that aren't Ed25519

- Bad entropy sources for generating primes and keys

- SSL (not TLS)

- Dumb Certificate Authorities (Equifax, Verisign) that get breached

- Packet replay attacks

## In the Web

- Plain HTTP (no encryption)

- Code-injection attacks (SQL injection, XSS, buffer overflows and exploits)

- Remote code execution (RCE) attacks (malformed packets, and co.)

- Session / cookie stealing

- CSRF

- Other things on the [OWASP Top 10](https://owasp.org/www-project-top-ten/)

- Plaintext passwords and passwords that aren't hashed using a slow cryptographic hash (bcrypt) > 512 bits

- Reused passwords

- Weak password

- Default passwords

## In sidechannels

- clflush + rdtsc for all privilege levels on x86 and x86-64

- Branching on secret and sensitive data

- Speculating past faults ([meltdown](https://meltdownattack.com/))

- Speculating past bounds and security checks ([spectre](https://meltdownattack.com/))

- Unrestricted access to microarchitecture (cache, TLB, store buffers, etc.)

- Side channels in general (especially the cache sidechannel)

## In general

- "Security by obscurity" relying on secrets in your code that people won’t find

  - Assuming your code is private and storing secrets in your code

- IoT security and non-existent cryptography

  - Blind trust of sensor data without accounting for noise contributed by an attacker

- Windows security

- Bad endpoint and user security practices

- Code that is susceptible to reverse-engineering, i.e no obfuscation is employed

- Assuming the user doesn’t want to ruin your life, either intentionally or unintentionally

## In programs (C/C++ ones, mostly)

- Buffer overread

- Buffer overflow

- Integer overflow

- Not sanitizing user inputs and queries

- strcpy, sprintf, gets, getpw, scanf and fscanf on strings without length checks

- User-inputted format strings

- C being dumb

- Control flow integrity compromises

- Return to libc

- Gadgets of all kind

## In contrast, the things we need

- Secure keys and key distribution

- TLS, mTLS

- Certs and automated cert management and renewal

- Confidentiality, Authenticity, Non-Repudiation, Integrity, and Privacy
