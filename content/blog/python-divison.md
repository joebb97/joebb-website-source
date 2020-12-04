---
title: "The Curious Case of Dividing Numbers in Python"
date: 2020-11-27
draft: false
categories: [python]
author: Joey Buiteweg
---

## Positive Numbers
If you're in the market for converting form python2 to python3, be aware that there's some fundamental differences in default division of integers. Also beware that these differences won't be automagically resolved by the tool [2to3](https://docs.python.org/3/library/2to3.html).

```python3
$ python3
Python 3.8.5 (default, Jul 21 2020, 10:42:08)
[Clang 11.0.0 (clang-1100.0.33.17)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> 5 / 3
1.6666666666666667
>>>
```

```python
$ python
Python 2.7.16 (default, Jan 27 2020, 04:46:15)
[GCC 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.37.14)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> 5 / 3
1
>>>
```

As you can see, the `/` operator in python3 leads to floating point divison by default, which can lead to problems if you're doing something like calculating memory page indices!
```python
index = addr / self.PAGE_SIZE
```

To access the integer division behavior in python3, you'll need to use the `//` operator. The code above becomes
```python
index = addr // self.PAGE_SIZE
```
```python3
$ python3
Python 3.8.5 (default, Jul 21 2020, 10:42:08)
[Clang 11.0.0 (clang-1100.0.33.17)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> 5 // 3
1
>>>
```

## Negative Numbers

Things get even more interesting when dealing with negative numbers and rounding.
```python
$ python
Python 2.7.16 (default, Jan 27 2020, 04:46:15)
[GCC 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.37.14)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> 5 / -3
-2
>>> int(5 / -3)
-2
>>>
```

```python3
$ python3
Python 3.8.5 (default, Jul 21 2020, 10:42:08)
[Clang 11.0.0 (clang-1100.0.33.17)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> 5 / -3
-1.6666666666666667
>>> 5 // -3
-2
>>> int(5 / -3)
-1
>>>
```

From what I can tell, both python2 and python3 round towards negative infinity when doing integer division (`/` in python2 with integer divider and dividend, `//` in python3 with integer divider and dividend). They also do the same thing when converting a negative floating point number to an integer, which is to round towards zero.

```python
$ python
Python 2.7.16 (default, Jan 27 2020, 04:46:15)
[GCC 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.37.14)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> int(5.0 / -3)
-1
>>>
```

```python3
$ python3
Python 3.8.5 (default, Jul 21 2020, 10:42:08)
[Clang 11.0.0 (clang-1100.0.33.17)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> int(5.0 / -3)
-1
>>>
```

## Compared to C++

Integer division truncation with negative numbers is different in C++, unfortunately.
```python
$ python
Python 2.7.16 (default, Jan 27 2020, 04:46:15)
[GCC 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.37.14)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> 5 / -3
-2
>>>
```

```python3
$ python3
Python 3.8.5 (default, Jul 21 2020, 10:42:08)
[Clang 11.0.0 (clang-1100.0.33.17)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> 5 // -3
-2
```

```cpp
#include <iostream>
// a.cpp

int main(){
    std::cout << int(5 / -3) << std::endl;
    std::cout << int(5.0 / -3) << std::endl;

}
```

```bash
$ g++ a.cpp ; ./a.out
-1
-1
```

Thankfully the behavior for converting a negative floating point number to an `int` has the same behavior between the three languages (as shown by the output of `int(5.0 / -3)` in C++).

Subtle differences in basic behavior of programming languages are always a joy to stumble across at the most inopportune times.
