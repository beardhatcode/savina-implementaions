# Pony Basics

<style scoped>

dl{counter-reset: item1;}

dt:before {
counter-increment: item1; content:
counter(item1) ". ";
}
dt {
  font-weight: bold;
}
dd {
  margin-left: 2em;
  
}
code {
  background: rgba(200,200,200,.1) !important;;
  border-color: rgba(200,200,200,.3);
}
</style>

Pony is one of the languages that provides "fearless concurrency".
The way this is done in Pony is trough capabilities.

## Capabilities

### Reference capabilities

We'll start with a brief introduction to capabilities, starting with reference capabilities.
These state in which way you can use a reference to a piece of memory (that is a variable). 


`iso` = *Isolate*. (RW, no aliased, can be passed)
:  If you have an `iso` variable, this means that you are certain that there is no other alias to that piece of memory with read (or write) acces.
  It is safe to read, and write to this variable. You can pass an `iso` to an other actor if you also pass the ownership by using `consume`.

`trn` = *Transition*. (RW, can have R aliases, cannot be passed)
:  A `trn` variable is designed to create a read only variable. 
  Having one allows you to make edits to its contents and allows you to create read only variants of it (`box`es).
  These read-only variants can't be passed to other actors but may come in handy when constructing your read only data.
  For example when you are creating a `val` data structure with cyclic references.

`box` = *Box*. (R, can have R and RW aliases, cannot be passed)
:  This box should be thought of as a transparent one with a slot.
  You can read its (internal public) data but you cannot alter its state trough function calls.
  You can still send messages to it if it is an actor


`ref` = *Reference* (RW, other aliases may be RW, cannot be passed).
:  A `ref` variable is your default reference capability. It states that you can modify the data the variable is pointing and that there may be other aliases with the same RW capability.

`val` = *Value*. (R, can have R aliases, can be passed)
:  A `val` reference to data implies that all references to that data are read-only.
  You can safely use the data without worrying about concurrency problems.

`tag` = *Tag*. (only allows sending of messages, can be passed)
:  A `tag` variable references a place in memory that has no guarantees. The only thing you can do is send a message to it. Since it a `tag` does not allow changing the internals directly it can be passed without problem.

#### Giving up aliases

The `iso` reference capability only allows one alias to exist. 
If you want to pass an `iso` varaible `b` to an other actor `a` you cannot simply do the following:

```
a.give(b)
```

This is because issuing that expression creates a new alias of `b` in the body of `a.give`.
If you want to do this, you must destroy your own alias by using consume:

```
a.give(consume b)
```

#### Using capability subtypes

There is a hierarchy to these capabilities. And you can create an alias for a variable of a lower capability. the following image shows the possibilities for subtyping:

![IMG TODO](todo)

### Receiver reference capabilites

Reference capabilities are checked when you are trying to access the value or the fields of a variable. If you have an `iso` variable you can read any of its `iso` or `val` fields. All other types of fields are read as a `tag`. 

At first, that seems odd, you might be wondering "If I have an iso why can't I read its `ref` field?" The reason is that an iso must maintain the property that it is isolated and that there is thus no other alias that can read or write to that memory. This includes its fields. If you were able to make an alias to one on the `ref` fields of an `iso` variable, you could still read from and write to the internals of the `iso` trough the alias of this `ref` field even if you passed the `iso` to an other actor. The same holds for `trn` and `box` fields. `val` Fields are fine because they are immutable, and they are thus always safe to read.

The following table summarised the restictions. The row indicates your capabilitiy on an object, the collumn specifies the capability the object itselves has on the filed you are trying to access. Because you can't read fields form a tag, that row only contains "n/a".


| &#x25B7;        | iso field | trn field | ref field | val field | box field | tag field |
|-----------------|-----------|-----------|-----------|-----------|-----------|-----------|
| __iso origin__  | iso       | tag       | tag       | val       | tag       | tag       |
| __trn origin__  | iso       | trn       | box       | val       | box       | tag       |
| __ref origin__  | iso       | trn       | ref       | val       | box       | tag       |
| __val origin__  | val       | val       | val       | val       | val       | tag       |
| __box origin__  | tag       | box       | box       | val       | box       | tag       |
| __tag origin__  | n/a       | n/a       | n/a       | n/a       | n/a       | n/a       |


When you are calling a method on an object, the reestrictions from teh call-site still need to hold. You can't call the method `setRefField(...)` on an `iso` varaible. For this reason functions are annotated with a *receiver reference capability*. You can only call a method that is compatible with your capabilities on the object. The default receiver reference capability of a method is `box`.




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
```
