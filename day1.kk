import std/data/sort
import std/os/path
import std/os/file

fun test-part1()
  val p = "./input/day1.txt".path
  val lns = p.read-text-file.lines
  val pairs = lns.map(fn(l) l.split("   ").map(fn(i) i.trim.parse-int.unjust))
  val first = pairs.map(fn(n) n[0].unjust).sort()
  val second = pairs.map(fn(n) n[1].unjust).sort()
  println(first.length)
  println(second.length)
  println(first.zip(second).map(fn((f, s)) (s - f).abs).sum)

fun test-part2()
  val p = "./input/day1.txt".path
  val lns = p.read-text-file.lines
  val pairs = lns.map(fn(l) l.split("   ").map(fn(i) i.trim.parse-int.unjust))
  val first = pairs.map(fn(n) n[0].unjust)
  val second = pairs.map(fn(n) n[1].unjust)
  println(first.map(fn(n) second.filter(fn(s) s == n).length * n).sum)