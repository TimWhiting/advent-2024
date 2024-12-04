import std/os/path
import std/os/file

struct wordsearch
  vals: vector<vector<int>>
  rows: int
  columns: int

fun parse(l: list<list<char>>): list<list<int>>
  with line <- l.map
  with char <- line.map
  match char
    'X' -> 1 // * 1
    'M' -> 2 // * 10
    'A' -> 3 // * 100
    'S' -> 4 // * 1000  Correct will be 4321
    _ -> 0

effect yield<t>
  fun yield(v: t): ()

fun iterate(ws: wordsearch, xi: int, yi: int, dx: int, dy: int): <pure,yield<int>> ()
  var x := xi
  var y := yi
  while {x >= 0 && x < ws.columns && y >= 0 && y < ws.rows}
    // trace(x.show ++ "," ++ y.show)
    yield(ws.vals[y][x])
    x := x + dx
    y := y + dy

fun iter-batched(x: int, f: () -> <pure,yield<t>> ()): <pure,yield<list<t>>> ()
  var batch := Nil
  with handler
    fun yield(a)
      batch := Cons(a, batch)
      if batch.length == x then
        yield(batch.reverse)
        batch := batch.take(x - 1)
  f()

fun topleftedge(ws: wordsearch, f: (int, int) -> e ()): e ()
  for(ws.rows) fn(r) f(0, r)
  for(1, ws.columns - 1) fn(c) f(c, 0)

fun toprightedge(ws: wordsearch, f: (int, int) -> e ()): e ()
  for(ws.rows) fn(r) f(0, r)
  for(1, ws.columns - 1) fn(c) f(c, ws.rows - 1)

fun bottomleftedge(ws: wordsearch, f: (int, int) -> e ()): e ()
  for(ws.rows) fn(r) f(ws.columns - 1, r)
  for(0, ws.columns - 2) fn(c) f(c, 0)

fun bottomrightedge(ws: wordsearch, f: (int, int) -> e ()): e ()
  for(ws.rows) fn(r) f(ws.columns - 1, r)
  for(0, ws.columns - 2) fn(c) f(c, ws.rows - 1)
  
fun test2()
  val ws = Wordsearch([[1,2,3], [4,5,6], [7,8,9]].map(vector).vector, 3, 3)
  trace("TL")
  topleftedge(ws) fn(x, y) trace(ws.vals[x][y].show)
  trace("TR")
  toprightedge(ws) fn(x, y) trace(ws.vals[x][y].show)
  trace("BL")
  bottomleftedge(ws) fn(x, y) trace(ws.vals[x][y].show)
  trace("BR")
  bottomrightedge(ws) fn(x, y) trace(ws.vals[x][y].show)

fun iter-all(ws: wordsearch): <pure,yield<list<int>>> ()
  // trace("left to right, row by row")
  for(ws.rows) fn(r) 
    iter-batched(4)
      iterate(ws, 0, r, 1, 0) // For each row, move across the columns to the right
  // trace("right to left, by row")
  for(ws.rows) fn(r)
    iter-batched(4)
      iterate(ws, ws.columns - 1, r, -1, 0) // Move backwards
  // trace("top to bottom, by column")
  for(ws.columns) fn(c)
    iter-batched(4)
      iterate(ws, c, 0, 0, 1) // For each column, move down the rows
  // trace("bottom to top, by column")
  for(ws.columns) fn(c)
    iter-batched(4)
      iterate(ws, c, ws.rows - 1, 0, -1) // For each column, move up the rows
  // trace("diagonal topleft to bottom right")
  topleftedge(ws) fn(r, c)
    iter-batched(4)
      iterate(ws, c, r, 1, 1)
  toprightedge(ws) fn(r, c)
    iter-batched(4)
      iterate(ws, c, r, -1, 1)
  bottomleftedge(ws) fn(r, c)
    iter-batched(4)
      iterate(ws, c, r, 1, -1)
  bottomrightedge(ws) fn(r, c)
    iter-batched(4)
      iterate(ws, c, r, -1, -1)
  

fun count(ws: wordsearch)
  var total := 0
  with handler
    fun yield(vals:list<int>)
      if vals[0].unjust == 1 && vals[1].unjust == 2 && vals[2].unjust == 3 && vals[3].unjust == 4 then
        total := total + 1
  iter-all(ws)
  total

fun test1()
  with handler
    fun yield(vals:list<int>)
      trace(vals.show)
  // [[0,1,2,3,4],
  //  [5,6,7,8,9],
  //  [10,11,12,13,14],
  //  [15,16,17,18,19],
  //  [20,21,22,23,24]]
  val res = list(0,4).map(fn(i) list(0,4).map(fn(j) i*5 + j))
  trace(res.show)
  iter-all(Wordsearch(res.map(vector).vector, 5, 5))

fun test-part1()
  val p = "./input/day4.txt".path
  val input = p.read-text-file.lines
  val inx = parse(input.map(list)).map(vector).vector
  count(Wordsearch(inx, inx.length, inx[0].length))


fun centers(ws: wordsearch) // Center of 3x3 grid
  for(1, ws.columns - 2) fn(c)
    for(1, ws.rows - 2) fn(r)
      yield((r,c))

fun diagoffsets()
  yield(((-1,-1),(1,1)))
  yield(((1,1),(-1,-1)))
  yield(((-1,1),(1,-1)))
  yield(((1,-1),(-1,1)))

fun xcoords()
  with handler
    fun yield(off1: ((int, int), (int, int)))
      val ((x1, y1), (x2, y2)) = off1
      with handler 
        fun yield(off2: ((int, int), (int, int)))
          val ((ox1, oy1), (ox2, oy2)) = off2
          // The same diagonal in different orders will not be valid anyways, but we will trim them since we don't want to check more than needed
          // Better would to not generate them in the first place
          if (off2 != off1 && (off2 != (off1.snd, off1.fst))) then 
            yield((((x1, y1), (x2, y2)), ((ox1, oy1), (ox2, oy2))))
      diagoffsets() 
  diagoffsets()

effect ctl found(): a

fun testoff(ws : wordsearch, c: int, r: int)
  if ws.vals[r][c] != 3 then False
  else 
    with handler
      ctl found()
        True
      return(_)
        False
    with handler
      fun yield(off: (((int, int), (int, int)), ((int, int), (int, int))))
        val ((x1, y1), (x2, y2)) = off.fst
        val ((ox1, oy1), (ox2, oy2)) = off.snd
        if ws.vals[r + x1][c + y1] == 2 && ws.vals[r + x2][c + y2] == 4 && ws.vals[r + ox1][c + oy1] == 2 && ws.vals[r + ox2][c + oy2] == 4 then
          found()
        else ()
    xcoords()

fun count2(ws: wordsearch)
  var total := 0
  with handler
    fun yield(tup: (int, int))
      if testoff(ws, tup.fst, tup.snd) then
        total := total + 1
  centers(ws)
  total

fun test-part2()
  val p = "./input/day4.txt".path
  val input = p.read-text-file.lines
  val inx = parse(input.map(list)).map(vector).vector
  count2(Wordsearch(inx, inx.length, inx[0].length))