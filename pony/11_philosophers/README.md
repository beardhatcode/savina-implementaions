# Pony

Pony is one of the languages that provides "fearless concurrency".
The way this is done in Pony is trough capabilities.

We'll start with a brief introduction to capabilities, starting with reference capabilities.
These state in which way you can use a reference to a piece of memory (that is a variable). 

1. `iso` = *Isolate*. (RW, no aliased, can be passed)
  If you have an `iso` variable, this means that you are certain that there is no other reference to that piece of memory.
  It is safe to read, and write to this variable. You can even pass it to an other actor by `consume`ing it.
1. `trn` = *Transition*. (RW, can have R aliases, cannot be passed)
  A `trn` variable is designed to create a read only variable. 
  Having one allows you to make edits to its contents and allows you to create read only variants of it (`box`es).
  These read-only variants can't be passed to other actors but may come in handy when constructing your read only data.
  For example when you are creating a `val` data structure with cyclic references.
  A `trn` can be converted to a `val` by `consume`ing it. <!-- TRUE?-->
1. `box` = *Box*. (R, can have R and RW aliases, cannot be passed)
  This box should be thought of as a transparent one with a XXXX <!-- gleuf -->.
  You can read its (internal public) data but you cannot alter its state trough function calls.
  You can still send messages to it if it is an actor
1. `val` = *Value*. (R, can have R aliases, can be passed)
  A `val` reference to data implies that all references to that data are read-only.
  You can safely use the data without worrying about concurrency problems.
1. `tag` = *Tag*. (only allows sending of messages)


of you have a `val` variable. 

# First attempt: bare bone actors

To get some feeling with pony we wil start out without fancy promices.
We'll use plain messages.




Result of

    cat /tmp/a | grep '^@' | sort -k2,2 -t' ' -n | uniq -c

```
     22 @EATING 0
     52 @THINK 0
     17 @EATING 1
     57 @THINK 1
     25 @EATING 2
     49 @THINK 2
     18 @EATING 3
     56 @THINK 3
     20 @EATING 4
     54 @THINK 4
     16 @EATING 5
     58 @THINK 5
     23 @EATING 6
     51 @THINK 6
     17 @EATING 7
     57 @THINK 7
     22 @EATING 8
     52 @THINK 8
     16 @EATING 9
     58 @THINK 9
     23 @EATING 10
     51 @THINK 10
     17 @EATING 11
     57 @THINK 11
     19 @EATING 12
     55 @THINK 12
     19 @EATING 13
     55 @THINK 13
     20 @EATING 14
     54 @THINK 14
     20 @EATING 15
     54 @THINK 15
     20 @EATING 16
     54 @THINK 16
     18 @EATING 17
     56 @THINK 17
     20 @EATING 18
     54 @THINK 18
     21 @EATING 19
     53 @THINK 19
     19 @EATING 20
     55 @THINK 20
     22 @EATING 21
     52 @THINK 21
     18 @EATING 22
     56 @THINK 22
     20 @EATING 23
     54 @THINK 23
     19 @EATING 24
     55 @THINK 24
     22 @EATING 25
     52 @THINK 25
     19 @EATING 26
     55 @THINK 26
     21 @EATING 27
     53 @THINK 27
     21 @EATING 28
     53 @THINK 28
     19 @EATING 29
     55 @THINK 29
     22 @EATING 30
     52 @THINK 30
     22 @EATING 31
     52 @THINK 31
     20 @EATING 32
     54 @THINK 32
     20 @EATING 33
     54 @THINK 33
     21 @EATING 34
     53 @THINK 34
     19 @EATING 35
     55 @THINK 35
     21 @EATING 36
     53 @THINK 36
     21 @EATING 37
     53 @THINK 37
     20 @EATING 38
     54 @THINK 38
     20 @EATING 39
     54 @THINK 39
     20 @EATING 40
     54 @THINK 40
     22 @EATING 41
     52 @THINK 41
     18 @EATING 42
     56 @THINK 42
     19 @EATING 43
     55 @THINK 43
     23 @EATING 44
     51 @THINK 44
     19 @EATING 45
     55 @THINK 45
     22 @EATING 46
     52 @THINK 46
     20 @EATING 47
     54 @THINK 47
     21 @EATING 48
     53 @THINK 48
     22 @EATING 49
     52 @THINK 49
     20 @EATING 50
     54 @THINK 50
     21 @EATING 51
     53 @THINK 51
     20 @EATING 52
     54 @THINK 52
     20 @EATING 53
     54 @THINK 53
     21 @EATING 54
     53 @THINK 54
     22 @EATING 55
     52 @THINK 55
     20 @EATING 56
     54 @THINK 56
     21 @EATING 57
     53 @THINK 57
     19 @EATING 58
     55 @THINK 58
     21 @EATING 59
     53 @THINK 59
     20 @EATING 60
     54 @THINK 60
     21 @EATING 61
     53 @THINK 61
     20 @EATING 62
     54 @THINK 62
     21 @EATING 63
     53 @THINK 63
     19 @EATING 64
     55 @THINK 64
     21 @EATING 65
     53 @THINK 65
     20 @EATING 66
     54 @THINK 66
     22 @EATING 67
     52 @THINK 67
     21 @EATING 68
     53 @THINK 68
     20 @EATING 69
     54 @THINK 69
     21 @EATING 70
     53 @THINK 70
     19 @EATING 71
     55 @THINK 71
     19 @EATING 72
     55 @THINK 72
     23 @EATING 73
     51 @THINK 73
     18 @EATING 74
     56 @THINK 74
     17 @EATING 75
     57 @THINK 75
     24 @EATING 76
     50 @THINK 76
     17 @EATING 77
     57 @THINK 77
     20 @EATING 78
     54 @THINK 78
     19 @EATING 79
     55 @THINK 79
     21 @EATING 80
     53 @THINK 80
     18 @EATING 81
     56 @THINK 81
     22 @EATING 82
     52 @THINK 82
     18 @EATING 83
     56 @THINK 83
     20 @EATING 84
     54 @THINK 84
     19 @EATING 85
     55 @THINK 85
     16 @EATING 86
     58 @THINK 86
     24 @EATING 87
     50 @THINK 87
     17 @EATING 88
     57 @THINK 88
     22 @EATING 89
     52 @THINK 89
     17 @EATING 90
     57 @THINK 90
     22 @EATING 91
     52 @THINK 91
     18 @EATING 92
     56 @THINK 92
     20 @EATING 93
     54 @THINK 93
     20 @EATING 94
     54 @THINK 94
     20 @EATING 95
     54 @THINK 95
     20 @EATING 96
     54 @THINK 96
     21 @EATING 97
     53 @THINK 97
     23 @EATING 98
     51 @THINK 98
     17 @EATING 99
     57 @THINK 99
```
