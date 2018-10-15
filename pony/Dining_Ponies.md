# Dining ponies
The dining philosophers problem in Pony. [Wikipedia](https://en.wikipedia.org/wiki/Dining_philosophers_problem) states the problem as follows:

> Five silent philosophers sit at a round table with bowls of spaghetti. Forks are placed between each pair of adjacent philosophers.
> 
> Each philosopher must alternately think and eat. However, a philosopher can only eat spaghetti when they have both left and right forks. Each fork can be held by only one philosopher and so a philosopher can use the fork only if it is not being used by another philosopher. After an individual philosopher finishes eating, they need to put down both forks so that the forks become available to others. A philosopher can take the fork on their right or the one on their left as they become available, but cannot start eating before getting both forks.
>
> Eating is not limited by the remaining amounts of spaghetti or stomach space; an infinite supply and an infinite demand are assumed.
>
> The problem is how to design a discipline of behaviour (a concurrent algorithm) such that no philosopher will starve; i.e., each can forever continue to alternate between eating and thinking, assuming that no philosopher can know when  others may want to eat or think. 

# Actors based solution

Since Pony is an actors based programming language we take on this problem in the default actor way. 

When a philosopher wants to start eating, they request both sticks form the table (which is also and actor). Eating can only commence when both sticks are acquired. If the philosopher fails to acquire a stick, they go on to think a bit longer and try again later.

## Main

The main of the programme creates a able with 5 sticks and 5 philosophers.

```pony
actor Main
  new create(env: Env) =>
    let number  = USize(5)
    env.out.print("Let's eat!")
    let table = Table(number)
    for i in Range(0, number) do
      Philosopher(i,env, table, i, (i+1) % number)()
    end
```

## Stick class
We represent a stick using a class that has a default reference capability of `iso`. This means that there may be at most one actor in possession of a stick.

```pony
class iso Stick
  let _id:USize val

  new iso create(id':USize)=> _id = id'
  fun box id():USize => _id
  fun box eq(that: Stick box): Bool => this._id == that._id
```

## Table actor

A table actor gets a `USize` as argument to its constructor. This indicates the number of sticks and seats. An array is made of optional sticks (that is `None` or `Stick iso`).

```pony
actor Table
  let _sticks: Array[(Stick|None)] ref

  new create(num: USize) =>
    _sticks = Array[(Stick|None)]()
    for i in Range(0,num) do
      _sticks.push( Stick(i) )
    end
```
There are two messages the table actor accepts: `takeStick` and `realeaseStick`. They are both implemented as a behaviour in Pony. These behaviours are not the same as behaviours in other actor based languages.

For the first behaviour, we get a request for a certain stick and who to give it to. Because the sticks in our array are `iso` we cannot just take a stick with `_sticks(num)` and send it back to the philosopher as this would create a new alias. To solve this we perform a destructive read, using `update`. The return type of `Array.update` is a `(Stick iso|None)^`. This is an ephemeral type, which means that there are no aliases to the returned value. This means we can send it back to the philosopher.

```pony
  be takeStick(num: USize, who:Philosopher)=>
    try  who.stick(num, _sticks.update(num,None)?)
    else who.stick(num, None)
    end
```

When a stick is returned, it is sent with a `realeaseStick` call. We take that stick and use match to verify if we got a stick. Take not of how we use `consume` in the match. By doing this we do not create an extra alias to the stick. Our initial `stick` is consumed and placed in `s`.Since `s` is an `iso` we can call the `box` method `s.id()` to get the id of the stick such that we can put it back in the array at the right place. When placing the stick in the array we consume the stick `s` again.

```pony
  be realeaseStick(stick:(Stick iso | None)) =>
    try match (consume stick)
        | let s:Stick iso => _sticks.update(s.id(),consume s)?
    end end
```

## Philosopher actor
The philosopher is the most complicated actor.

To create one we save the number of the philosopher and the required sticks in instance variables. We also set the `_sticksPending`  tupple to `(false,false)`. This tupple keeps track of which sticks we have requested but haven't received or been denied. We also keep a `Rand` in the actor to generate random sleep times.

```pony
actor Philosopher
   ...

  new create(number': USize, env: Env, table: Table tag, left_stick:USize, right_stick:USize) =>
    number = number'
    _sticks = (left_stick,right_stick)
    _sticksOwn1 = None
    _sticksOwn2 = None
    _sticksPending = (false,false)
    _table = table
    _env = env
    rand = Rand(133742 + (number'.u64()))
```

The `apply` behaviour, which is called at the start of the program, waits a random amount of time and requests sticks.

```pony
  be apply() =>
    let l:Philosopher tag = this
    _env.out.print("@THINK " + number.string())
    this.doDelayed({(l:Philosopher tag) => l.requestSticks(); None })
```

This is done by simply sending a `takeStick` request to the table. After requesting sticks we must wait for a `stick` message as response form the table. To keep track of which sticks we do not have an answer for we set `_sticksPending` to `true` for both sticks.

```pony
  be requestSticks()=>
    _env.out.print("Request sticks " + number.string()) 
    _sticksPending = (true,true)
    _table.takeStick(_sticks._1,this)
    _table.takeStick(_sticks._2,this)
```

When `stick` messages arrive, we store the `Stick` or `None` in `_sticksOwn1` and `_sticksOwn2`. We update `_sticksPending`. If have gotten a response for all sticks, we validate that we have both sticks. If one of the sticks is missing we return all sticks we have. In the fortunate case that we have both sticks, we eat.

```pony
  be stick(num:USize, s: (Stick|None)) =>
    match (consume s)
    | let x:Stick => 
        if     x.id() == _sticks._1 then _sticksOwn1 = consume x
        elseif x.id() == _sticks._2 then _sticksOwn2 = consume x
        end
    end

    _sticksPending = (
      if num == _sticks._1 then false else _sticksPending._1 end, 
      if num == _sticks._2 then false else _sticksPending._2 end
    )

    if ((_sticksPending._1) or (_sticksPending._2)) then return end

    // Check if none of the sticks are None
    recover 
      match _sticksOwn1
      | None => this.returnSticks()
      else 
        match _sticksOwn2
        | None => this.returnSticks()
        else
          eat() // We have both sticks
        end
      end
    end
```

Eating is simple. We print that we are eating and return the sticks after some time.

```pony
  fun ref eat() =>
    state = Eating
    _env.out.print("@EATING " + number.string())
    this.doDelayed({(l:Philosopher tag) => l.returnSticks(); None } iso)
```

When the sticks are returned we set our state to `Thinking` and send back the sticks to the table. Since we mustn't create aliases to our `Sticks` we first use a destructive read to get the `iso` in a local variable we can consume. Once the sticks are sent we can go back to our `apply()`.
```pony
  be returnSticks() =>
    _env.out.print("Return sticks "+number.string())
    state = Thinking
    let s1 = _sticksOwn1 = None; _table.realeaseStick(consume s1)
    let s2 = _sticksOwn2 = None; _table.realeaseStick(consume s2)
    this()
```

