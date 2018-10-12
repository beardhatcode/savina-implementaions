use "time" 
use "random" 
use "collections" 

primitive Eating
primitive Thinking
type PhilosopherState is (Eating | Thinking)

// A class representing a stick
// It is iso(lated) by default because only one reference should exist
// to it. When a stick philosopher takes up the stick it should take the ownership
// By consuming the stick
class iso Stick
  let _id:USize val

  new iso create(id':USize)=> _id = id'
  fun box id():USize => _id
  fun box eq(that: Stick box): Bool => this._id == that._id


actor Table
  let _sticks: Array[(Stick|None)] ref

  new create(num: USize) =>
    _sticks = Array[(Stick iso|None)]()
    for i in Range(0,num) do
      _sticks.push( Stick(i) )
    end

  be takeStick(num: USize, who:Philosopher,number:USize)=>
    try
      who.stick(num, _sticks.update(num,None)?)
    else
      who.stick(num, None.create())
    end
    false

  be realeaseStick(stick:(Stick iso | None), x:Philosopher) =>
    try
      match (consume stick)
      | let s:Stick iso => _sticks.update(s.id(),consume s)?
      end
    end



actor Philosopher
  var state: PhilosopherState val = Thinking
  let _env: Env val
  let _sticks:(USize,USize)
  var _sticksOwn1:(Stick iso|None)
  var _sticksOwn2:(Stick iso|None)
  var _sticksPending:(Bool,Bool)
  let _table:Table tag
  let number:USize val
  let rand:Rand

  new create(number': USize, env: Env, table: Table tag, left_stick:USize, right_stick:USize) =>
    number = number'
    _sticks = (left_stick,right_stick)
    _sticksOwn1 = None
    _sticksOwn2 = None
    _sticksPending = (false,false)
    _table = table
    _env = env
    rand = Rand(133742 + (number'.u64()))

  fun ref eat() =>
    state = Eating
    _env.out.print("@EATING " + number.string())
    this.doDelayed({(l:Philosopher tag) => l.returnSticks(); None } iso)


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

  be returnSticks() =>
    _env.out.print("Return sticks "+number.string())
    state = Thinking
    let s1 = _sticksOwn1 = None; _table.realeaseStick(consume s1, this)
    let s2 = _sticksOwn2 = None; _table.realeaseStick(consume s2, this)

    this()

  be requestSticks()=>
    _env.out.print("Request sticks " + number.string()) 
    _sticksPending = (true,true)
    _table.takeStick(_sticks._1,this,number)
    _table.takeStick(_sticks._2,this,number)

  be apply() =>
    let l:Philosopher tag = this
    _env.out.print("@THINK " + number.string())
    this.doDelayed({(l:Philosopher tag) => l.requestSticks(); None })


  be doDelayed(doIt:({box(Philosopher tag):None tag} val)) =>
    let philosopherTag:Philosopher tag = this
    let timers = Timers
    let timer = Timer(recover iso object iso is TimerNotify 
          fun ref apply(timer: Timer ref, count: U64 val) : Bool val=> 
            doIt(philosopherTag)
            false
          fun ref cancel( timer: Timer ref) => None.create()
          end end
        , (rand.next())/36893487000, 0) // rand.next()
    timers(consume timer)
    None

    

actor Main
  new create(env: Env) =>
    let number  = USize(20)
    env.out.print("Let's eat!")
    let table = Table(number)
    for i in Range(0, number) do
      Philosopher(i,env, table, i, (i+1) % number)()
    end
/*
"""
- promises
- neerschrijven
- E
- Elexir
"""
*/