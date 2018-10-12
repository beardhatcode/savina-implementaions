use "time" 
use "random" 
use "collections" 

primitive Eating
primitive Thinking
type PhilosopherState is (Eating | Thinking)

class iso Stick
  let _id:USize val

  new create(id':USize)=> _id =  id'
  fun box id():USize => _id
  fun box eq(that: Stick box): Bool => this._id == that._id


actor Table
  let _env: Env val
  let _sticks: Array[(Stick iso|None)] ref

  new create(env: Env, num: USize) =>
    _sticks = Array[(Stick iso|None)]()
    for i in Range(0,num) do
      _sticks.push(recover Stick(i) end)
    end
    _env = env



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
  let rand:Rand = Rand()

  new create(number': USize, env: Env, table: Table tag, left_stick:USize, right_stick:USize) =>
    number = number'
    _sticks = (left_stick,right_stick)
    _sticksOwn1 = None.create()
    _sticksOwn2 = None.create()
    _sticksPending = (false,false)
    _table = table
    _env = env

  fun ref eat() =>
    state = Eating
    _env.out.print("@EATING " + number.string())
    let l:Philosopher tag = this 

    let timers = Timers
    let timer = Timer(recover iso object is TimerNotify 
          fun ref apply(timer: Timer ref, count: U64 val) : Bool val=> state = Thinking; l.returnSticks(); false
          fun ref cancel( timer: Timer ref) => None.create()
          end end
        , rand.next()/3689348700, 0)
    timers(consume timer)


  be stick(num:USize, s: (Stick iso|None)) =>
  if ((_sticksPending._1 == false) and (_sticksPending._2 == false)) then return end
    match (consume s)
    | let x:Stick => 
        if (x.id() == _sticks._1) then
          _sticksOwn1 = consume x;_sticksPending = (false,_sticksPending._2)
        elseif x.id() == _sticks._2 then
          _sticksOwn2 =consume x;_sticksPending = (_sticksPending._1, false)
        end
    | None => _sticksPending = (if num == _sticks._1 then false else _sticksPending._1 end, if num == _sticks._2 then false else _sticksPending._2 end)
    end

    recover
    match _sticksOwn1
    | None => this.returnSticks()
    else
      match _sticksOwn2
      |   None => this.returnSticks()
      else
          eat()
      end
    end
    end

  be returnSticks() =>
    if ((_sticksPending._1) or (_sticksPending._2)) then return end
    _env.out.print("return sticks "+number.string())
    let s1 = _sticksOwn1 = None.create(); _table.realeaseStick(consume s1, this)
    let s2 = _sticksOwn2 = None.create(); _table.realeaseStick(consume s2, this)

    this()

  be requestSticks()=>
    _env.out.print("Request sticks " + number.string()) 
    _sticksPending = (true,true)
    _table.takeStick(_sticks._1,this,number)
    _table.takeStick(_sticks._2,this,number)

  be apply() =>
    let l:Philosopher tag = this
    _env.out.print("@THINK " + number.string())
    let timers = Timers
    let timer = Timer(recover iso object is TimerNotify 
          fun ref apply(timer: Timer ref, count: U64 val) : Bool val=> 
            l.requestSticks()
            false
          fun ref cancel( timer: Timer ref) => None.create()
          end end
        , rand.next()/3689348700, 0)
    timers(consume timer)


    

actor Main
  new create(env: Env) =>
    let number  = USize(20)
    env.out.print("Let's eat2!")
    let table = Table(env,number)
    for i in Range(0, number) do
      Philosopher(i,env, table, i, (i+1) % number)()
    end
