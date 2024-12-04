import std/data/sort
import std/os/path
import std/os/file

type state
  Total(total: int, pos: int)
  Do_Dont(total: int, pos: int)
  Do(total: int)
  Dont(total: int, pos: int)
  Start(total: int)
  StartNum(total: int, chars: list<char>)
  StartNum2(total: int, chars: list<char>, first: int)


fun read-int(l : list<char>): exn int
  l.reverse.string.parse-int.unjust // We built the string up backwards when collecting the digits

fun parse(l : list<char>, st : state): exn int
  match l
    Nil -> st.total
    Cons(c, rst) ->
      val next_state = match st
        Total(t, 0) -> if c == 'm' then Total(t, 1) else Total(t, 0)
        Total(t, 1) -> if c == 'u' then Total(t, 2) else Total(t, 0)
        Total(t, 2) -> if c == 'l' then Start(t) else Total(t, 0)
        Start(t) -> if c == '(' then StartNum(t, Nil) else Total(t, 0)
        StartNum(t, l2) -> 
          if c.is-digit then StartNum(t, Cons(c, l2)) 
          elif c == ',' then StartNum2(t, Nil, l2.read-int) 
          else Total(t, 0)
        StartNum2(t, l2, f) -> 
          if c.is-digit then StartNum2(t, Cons(c, l2), f) 
          elif c == ')' then Total(t + (f * l2.read-int), 0)
          else Total(t, 0)
        _ -> Total(st.total, 0)
      parse(rst, next_state)

fun test-part1()
  val p = "./input/day3.txt".path
  val input = p.read-text-file.list
  parse(input, Total(0, 0)).println


fun parse2(l : list<char>, st : state, current_do: bool): exn int
  match l
    Nil -> st.total
    Cons(c, rst) ->
      fun rest()
        parse2(rst, Total(st.total, 0), current_do)
      match (st, c)
        (_, 'd') -> parse2(rst, Do_Dont(st.total, 1), current_do)
        (Do_Dont(t, 1), 'o') -> parse2(rst, Do_Dont(t, 2), current_do)
        (Do_Dont(t, 2), 'n') -> parse2(rst, Dont(t, 3), current_do)
        (Do_Dont(t, 2), '(') -> parse2(rst, Do(t), current_do)
        (Do(t), ')') -> parse2(rst, Total(t, 0), True)
        (Dont(t, 3), '\'') -> parse2(rst, Dont(t, 4), current_do)
        (Dont(t, 4), 't') -> parse2(rst, Dont(t, 5), current_do)
        (Dont(t, 5), '(') -> parse2(rst, Dont(t, 6), current_do)
        (Dont(t, 6), ')') -> parse2(rst, Total(t, 0), False)
        _ -> 
          if !current_do then rest() // No need to check other cases
          else
            match (st, c)
              (Total(t, 0), 'm') -> parse2(rst, Total(t, 1), current_do)
              (Total(t, 1), 'u') -> parse2(rst, Total(t, 2), current_do)
              (Total(t, 2), 'l') -> parse2(rst, Start(t), current_do)
              (Start(t), '(') -> parse2(rst, StartNum(t, Nil), current_do)
              (StartNum(t, l2), c) -> 
                if c.is-digit then parse2(rst, StartNum(t, Cons(c, l2)), current_do)
                elif c == ',' then parse2(rst, StartNum2(t, Nil, l2.read-int), current_do)
                else rest()
              (StartNum2(t, l2, f), c) ->
                if c.is-digit then parse2(rst, StartNum2(t, Cons(c, l2), f), current_do)
                elif c == ')' then parse2(rst, Total(t + (f * l2.read-int), 0), current_do)
                else rest()
              _ -> rest()

fun test-part2()
  val p = "./input/day3.txt".path
  val input = p.read-text-file.list
  parse2(input, Total(0, 0), True).println

