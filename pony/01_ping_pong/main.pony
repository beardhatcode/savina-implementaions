actor Ping
  let buddy: Pong tag
  var _count: U8 val
  let _env: Env val

  new create(env: Env, count: U8 val, pong: Pong) =>
    buddy = pong
    _env = env
    _count = count

  be apply() =>
    if _count > 0 then
      _env.out.print("Ping! " + _count.string())
      buddy(this)
      _count = _count - 1
    end

actor Pong
  let _env: Env val
  var _count: U8 val

  new create(env: Env) =>
    _env = env
    _count = 0

  be apply(buddy: Ping tag) =>
    _count = _count + 1
    _env.out.print("Pong! " + _count.string())
    buddy()


actor Main
  new create(env: Env) =>
    env.out.print("Hello, world!")
    let other = Pong(env)
    Ping(env, U8(17), other)()
