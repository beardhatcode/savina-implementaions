use "time" 
use "random" 
use "collections" 
primitive Eating 
primitive Thinking


actor Table
  let _env: Env val
  let _sticks: Array[Bool] ref

  new create(env: Env, num: USize) =>
    _sticks = Array[Bool].init(true,num)
    _env = env



  be takeStick(num: USize, who:Philosopher,number:USize) =>

    try
      if _sticks(num)? == true then
        _sticks.update(num,false)?
        who.stick(num,true)
        return
      end
    end
    who.stick(num,false)

  be realeaseStick(num: USize,who:Philosopher) =>
    try
      if _sticks(num)? == false then
        _sticks.update(num,true)?
      end
    end

  



actor Philosopher
  var state: Bool val = true
  let _env: Env val
  let _sticks:(USize,USize)
  var _sticksOwn:(Bool,Bool)
  var _sticksPending:(Bool,Bool)
  let _table:Table tag
  let number:USize val
  let rand:Rand = Rand()

  new create(number': USize, env: Env, table: Table tag, left_stick:USize, right_stick:USize) =>
    number = number'
    _sticks = (left_stick,right_stick)
    _sticksOwn = (false,false)
    _sticksPending = (false,false)
    _table = table
    _env = env

  fun ref eat() =>
    state = true
    _env.out.print("@EATING " + number.string())
    let l:Philosopher tag = this 

    let timers = Timers
    let timer = Timer(recover iso object is TimerNotify 
          fun ref apply(timer: Timer ref, count: U64 val) : Bool val=> state = false; l.returnSticks(); false
          fun ref cancel( timer: Timer ref) => None.create()
          end end
        , rand.next()/36893487000, 0)
    timers(consume timer)


  be stick(num:USize, have:Bool) =>
  if ((_sticksPending._1 == false) and (_sticksPending._2 == false)) then return end
    if _sticks._1 == num then
      _sticksPending = (false,_sticksPending._2)
      _sticksOwn = (have,_sticksOwn._2)
    end
    if _sticks._2 == num then
      _sticksPending = (_sticksPending._1, false)
      _sticksOwn = (_sticksOwn._1,have) 
    end
    // Something has changed
    _env.out.print("Stick got "+number.string()+"  "+have.string()+" ("+_sticksOwn._1.string()+_sticksOwn._2.string()+")")
    if (_sticksOwn._1 and _sticksOwn._2) then
      this.eat()
    else
      if ((_sticksPending._1 == false) and (_sticksPending._2 == false)) then
        this.returnSticks()
      end
    end

  be returnSticks() =>
    _env.out.print("return sticks "+number.string())
    var oldOwn = _sticksOwn = (false,false)
    if oldOwn._1 then _table.realeaseStick(_sticks._1,this) end
    if oldOwn._2 then _table.realeaseStick(_sticks._2,this) end
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
        , rand.next()/36893487000, 0)
    timers(consume timer)


    

actor Main
  new create(env: Env) =>

    env.out.print("Let's eat2!")
    let table = Table(env,100)
    for i in Range(0, 100) do
      Philosopher(i,env, table, i, (i+1) % 100)()
    end
