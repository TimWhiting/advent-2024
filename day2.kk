import std/data/sort
import std/os/path
import std/os/file

fun bad-change(n)
  n == 0 || n > 3

fun check-level(l : list<int>)
  match l
    Cons(a, Cons(b, rst)) -> 
      val diff = (a - b).abs
      if bad-change(diff) then False
      elif a < b then check-increasing(Cons(b, rst)) 
      elif a > b then check-decreasing(Cons(b, rst))
      else False
    _ -> True

fun check-increasing(l : list<int>)
  match l
    Cons(a, Cons(b, rst)) -> 
      if a >= b || bad-change((a - b).abs) then False
      else check-increasing(Cons(b, rst))
    _ -> True

fun check-decreasing(l : list<int>)
  match l
    Cons(a, Cons(b, rst)) -> 
      if a <= b || bad-change((a - b).abs) then False
      else check-decreasing(Cons(b, rst))
    _ -> True

fun test-part1()
  val p = "./input/day2.txt".path
  val lns = p.read-text-file.lines
  println(lns.map(fn(l) l.split(" ").map(fn(i) i.trim.parse-int.unjust)).filter(check-level).length)


fun remove(l : list<int>, i: int)
  match l
    Nil -> Nil
    Cons(a, rst) -> if i == 0 then rst else Cons(a, remove(rst, i - 1))

fun all-levels(l : list<int>): list<list<int>>
  list(0,l.length - 1).map(fn(i) remove(l, i))
  
fun check-level2(l : list<int>): div bool
  l.all-levels.any(check-level)

fun test-part2()
  val p = "./input/day2.txt".path
  val lns = p.read-text-file.lines
  println(lns.map(fn(l) l.split(" ").map(fn(i) i.trim.parse-int.unjust)).filter(check-level2).length)

