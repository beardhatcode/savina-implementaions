# Language comparison



## Savina Benchmark

List of [Savina benchmarks](savina/savina.pdf).

|    # | Name                                  | Symbol | Feature or Pattern being measured                            | Source                                                       |
| ---: | ------------------------------------- | :----: | ------------------------------------------------------------ | ------------------------------------------------------------ |
|      | **micro-benchmarks**                  |        |                                                              |                                                              |
|    1 | Ping Pong                             |   PP   | Message delivery overhead                                    | [Scala](http://www.scala-lang.org/node/54)                   |
|    2 | Counting Actor                        | COUNT  | Message passing overhead                                     | [Theron](http://www.theron-library.com/index.php?t=page&p=countingactor) |
|    3 | Fork Join (throughput)                |  FJT   | Messaging throughput                                         | [JGF](http://www2.epcc.ed.ac.uk/computing/research_activities/java_grande/threads/s1contents.html) , ourselves |
|    4 | Fork Join (actor creation)            |  FJC   | Actor creation and destruction                               | [JGF](http://www2.epcc.ed.ac.uk/computing/research_activities/java_grande/threads/s1contents.html) , ourselves |
|    5 | Thread Ring                           |  THR   | Message sending; Context switching between actors            | [Theron](http://www.theron-library.com/index.php?t=page&p=countingactor) |
|    6 | Chameneos                             |  CHAM  | Contention on mailbox; Many-to-one message passing           | [Haller](https://codereview.scala-lang.org/fisheye/browse/scala-svn/scala/branches/translucent/docs/examples/actors/chameneos-redux.scala?hb=true) |
|    7 | Big                                   |  BIG   | Contention on mailbox; Many-to-Many message passing          | [BenchErl](http://doi.acm.org/10.1145/2364489.2364495)       |
|      | **concurrency**                       |        |                                                              |                                                              |
|    8 | Concurrent Dictionary                 | CDICT  | Reader-Writer concurrency; Constant-time data structure      | Ourselves                                                    |
|    9 | Concurrent Sorted Linked-List         |  CSLL  | Reader-Writer concurrency; Linear-time data structure        | [Shirako et al.](http://doi.acm.org/10.1145/2312005.2312015) |
|   10 | Producer-Consumer with Bounded Buffer |  PCBB  | Multiple message patterns based on Join calculus             | [Sulzmann et al.](https://www.researchgate.net/profile/Martin_Sulzmann/publication/220993985_Actors_with_Multi-Headed_Message_Receive_Patterns/links/00b495297d66f3b15b000000.pdf) |
|   11 | Dining Philosophers                   |  PHIL  | Inter-process communication; Resource allocation             | [Wikipedia](http://en.wikipedia.org/wiki/Dining_philosophers_problem) |
|   12 | Sleeping Barber                       |  SBAR  | Inter-process communication; State synchronization           | [Wikipedia](http://en.wikipedia.org/wiki/Sleeping_barber_problem) |
|   13 | Cigarette Smokers                     |  CIG   | Inter-process communication; Deadlock prevention             | [Wikipedia](http://en.wikipedia.org/wiki/Cigarette_smokers_problem) |
|   14 | Logistic Map Series                   |  LOGM  | Synchronous Request-Response with non-interfering transactions | [Wikipedia](http://en.wikipedia.org/wiki/Logistic_map)       |
|   15 | Bank Transaction                      |  BTX   | Synchronous Request-Response with interfering transactions   | Ourselves                                                    |
|      | **parallrlism**                       |        |                                                              |                                                              |
|   16 | Radix Sort                            | RSORT  | Static Pipeline; Message batching                            | [StreamIT](http://doi.acm.org/10.1145/1854273.1854319)       |
|   17 | Filter Bank                           | FBANK  | Static Pipeline; Split-Join Pattern                          | [StreamIT](http://doi.acm.org/10.1145/1854273.1854319)       |
|   18 | Sieve of Eratosthenes                 | SIEVE  | Dynamic Pipeline                                             | [GPars](http://www.gpars.org/guide/)                         |
|   19 | Unbalanced Cobwebbed Tree             |  UCT   | Non-uniform load; Tree exploration                           | [Zhao and Jamali](http://doi.acm.org/10.1145/2541329.2541337) |
|   20 | Online Facility Location              |  OFL   | Dynamic Tree generation and navigation                       | Ourselves                                                    |
|   21 | Trapezoidal Approximation             | TRAPR  | Master-Worker; Static load-balancing                         | [Stage](http://dx.doi.org/10.1109/IWMSE.2009.5071380)        |
|   22 | Precise Pi Computation                | PIPREC | Master-Worker; Dynamic load-balancing                        | Ourselves                                                    |
|   23 | Recursive Matrix Multiplication       |  RMM   | Uniform load; Divide-and-conquer style parallelism           | Ourselves                                                    |
|   24 | Quicksort                             | QSORT  | Non-uniform load; Divide-and-conquer style parallelism       | Ourselves                                                    |
|   25 | All-Pairs Shortest Path               |  APSP  | Phased computation; Graph exploration                        | Ourselves                                                    |
|   26 | Successive Over-Relaxation            |  SOR   | 4-point stencil computation                                  | [SOTER](http://osl.cs.uiuc.edu/soter/)                       |
|   27 | A-Star Search                         | ASTAR  | Message priority; Graph exploration                          | Ourselves                                                    |
|   28 | NQueens first N solutions             |  NQN   | Message priority; Divide-and-conquer style parallelism       | Ourselves                                                    |