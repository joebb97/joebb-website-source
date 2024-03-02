---
title: "A Python Oddity"
date: 2021-10-11
draft: false
categories: [python]
author: Joey Buiteweg
---

## The Oddity

Let's say you want to intialize a matrix (a two-dimensional `list`) in python. It'll be an NxN matrix of numbers. Just for fun we'll make all the inital elements `1`, instead of `0`.

One might think the following would be a sensible one-liner.

```python3
# sample.py
def print_mat(matrix):
    for row in matrix:
        print(row)

matrix = [[1] * 10] * 10
print_mat(matrix)
```

prints

```shell
$ python3 sample.py
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
```

**But**, what happens if we modify part of the matrix?

```python3
# sample.py
# same print_mat as above
matrix = [[1] * 10] * 10
print("--- BEFORE MOD ---")
print_mat(matrix)
matrix[0][3] = 89
print()
print("--- AFTER MOD ---")
print_mat(matrix)
```

prints

```shell
$ python3 sample.py
--- BEFORE MOD ---
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

--- AFTER MOD ---
[1, 1, 1, 89, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 89, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 89, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 89, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 89, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 89, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 89, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 89, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 89, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 89, 1, 1, 1, 1, 1, 1]
```

Oops! That clearly creates a list containing ten of the same list.

_(If you are confused, we would normally expect **only** the first row to have been modified to have the `89`, not all of the rows)_

## Explanation

To better illustrate what's going on, the above declaration of matrix

```python3
matrix = [[1] * 10] * 10
```

is really the same as

```python3
inner_list = [1] * 10
matrix = [inner_list] * 10
```

Since python variables are really just pointers to objects, we're making a list of ten of the same pointer to one object, in this case our `list` of ten ones.

## The Correct Way

It's pretty straight forward to fix this, we just use a list comprehension instead of the `*` shorthand, which produces this unexpected behavior when applied to a list of lists.

```python3
# sample.py
matrix = [[1] * 10 for _ in range(10)]
print("--- BEFORE MOD ---")
print_mat(matrix)
matrix[0][3] = 89
print()
print("--- AFTER MOD ---")
print_mat(matrix)
```

which produces the expected output

```shell
$ python3 sample.py
--- BEFORE MOD ---
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

--- AFTER MOD ---
[1, 1, 1, 89, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]


```

_Note: we could also say_
`matrix = [[1 for _ in range(10)] for _ in range(10)]`_, but that is more to type!_
