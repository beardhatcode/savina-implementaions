use "promises"
class PrintFulfill is Fulfill[String, String]
  let _env: Env
  let _msg: String
  new create(env: Env, msg: String) =>
    _env = env
    _msg = msg
  fun apply(s: String): String =>
    _env.out.print(" + ".join([s; _msg].values()))
    s

actor R
  be apply(p:Promise[String]) =>
    p("Large ")


actor Main
  new create(env: Env) =>
     let promise = Promise[String]
     promise.next[String](recover PrintFulfill(env, "magneto resistance") end)
     R(promise)
     promise.next[String](recover PrintFulfill(env, "bar") end)
     promise.next[String](recover PrintFulfill(env, "baz") end)
     let i:U64 = 