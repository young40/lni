local lni = require 'lni'
local print_r = require 'print_r'

function LOAD(filename)
	local f = assert(io.open(filename, 'rb'))
	local r = lni(f:read 'a')
	f:close()
	return r
end

local function EQUAL(a, b)
	for k, v in pairs(a) do
		if type(v) == 'table' then
			EQUAL(v, b[k])
		else
			assert(v == b[k])
		end
	end
end

local n = 0
local function TEST(script, t)
	n = n + 1
	local name = 'TEST-' .. n
	local r = lni(script, name)
	local ok, e = pcall(EQUAL, r, t)
	if not ok then
		print(script)
		print('--------------------------')
		print_r(r)
		print('--------------------------')
		print_r(t)
		print('--------------------------')
		error(name)
	end
	local ok, e = pcall(EQUAL, t, r)
	if not ok then
		print(script)
		print('--------------------------')
		print_r(r)
		print('--------------------------')
		print_r(t)
		print('--------------------------')
		error(name)
	end
end

TEST([==[
[A]
a = 1
]==]
,
{
 A = {a = 1}
}
)


TEST([==[
[A]
a = 1
[.B]
c = 2
]==]
,
{
 A = {a = 1, B = {c = 2}}
}
)

TEST([==[
[A]
a = 1
[.B]
[..C]
d = 2
]==]
,
{
 A = {a = 1, B = {C = {d = 2}}}
}
)

TEST([==[
a = 1
b = 2
]==]
,
{
 a = 1, b = 2
}
)

TEST([==[
[A]
a = 1
[B]
[.C]
b = 2
[.D]
c = 3
]==]
,
{
 A = {a = 1}, B = {C = {b = 2}, D = {c = 3}}
}
)

TEST([==[
[A]
a = 1
[A]
b = 2
]==]
,
{
 A = {b = 2}
}
)

TEST([==[
[A]
C = 2
[.B]
a = 1
]==]
,
{
 A = { B = {a = 1}, C = 2 }
}
)

TEST([==[
[A]
[.B]
a = 1
[A]
C = 2
]==]
,
{
 A = { C = 2 }
}
)


TEST([==[
[B]
C = {a = 1}
[A:B.C]
b = 2
]==]
,
{
 A = { a = 1, b = 2 },
 B = { C = { a = 1 } }
}
)

TEST([==[
<default>
a = 1
[A]
b = 0
]==]
,
{
 A = { a = 1, b = 0 }
}
)

TEST([==[
<default>
a = 1
[A]
[.B]
b = 0
]==]
,
{
 A = { a = 1, B = {b = 0} }
}
)

TEST([==[
[root]
a = 1
[default]
b = 2
]==]
,
{
  root = { a = 1 },
  default = { b = 2 },
}
)

TEST([==[
[A]
a = 1
b = 2
[B:A]
c = 3
]==]
,
{
  A = { a = 1, b = 2 },
  B = { a = 1, b = 2, c = 3 },
}
)


TEST([==[
[A]
a = "\10\0\9"
]==]
,
{
  A = { a = "\10\0\9" }
}
)

TEST([==[
[A]
a = [[ok]]
b = [[
ok]]
]==]
,
{
  A = {
  	a = "ok",
  	b = "ok",
  }
}
)

TEST([==[
[A] a = {1, {1, 2}}
]==]
,
{
  A = { a = {1, {1, 2}} }
}
)

TEST([==[
[A] a = false -- test
]==]
,
{
  A = { a = false }
}
)

TEST([==[
[A] a = 1
[A] b = 2
]==]
,
{
  A = { b = 2 }
}
)

TEST([==[
[A] a = 1
[.B] b = 2
[.C] c = 3
[D] d = 4
[.E] e = 5
]==]
,
{
  A = { a = 1, B = { b = 2 }, C = { c = 3 } },
  D = { d = 4, E = { e = 5 } }
}
)

TEST([==[
[A]
A1 = B 
A2 = B
]==]
,
{
  A = { A1 = "B", A2 = "B" }
}
)

TEST([==[
[A]
float = 0.12345678901234567890
mi = -1.01
]==]
,
{
  A = {
    float = 0.12345678901234567890,
    mi = -1.01,
  }
}
)

TEST([==[
[a:b]
[c:d]
]==]
,
{
  a = {},
  b = {},
  c = {},
  d = {},
}
)

TEST([==[
[A]
````````
a = 1
````````
b = 2
]==]
,
{
  A = {{a=1},{b=2}},
}
)

TEST([==[
[A]
````````
a = 1
````````
b = 2
[B]
c = 3
]==]
,
{
  A = {{a=1},{b=2}},
  B = {c=3},
}
)

TEST([==[
[[A]]
a = 1
````````
b = 2
````````
c = 3
[B]
c = 3
]==]
,
{
  A = {{a=1},{b=2},{c=3}},
  B = {c=3},
}
)


TEST([==[
[a]
b = 0xFF
]==]
,
{
  a = { b = 255 }
}
)

TEST(
[==[
[ABC]
a = 'Hello'
b = 1.0
c = {'1', '2', '3'}
'd' = {
  x = 2,
  y = 4,
  5 = 5,
}
e = true
f = nil
10 = [[
   | H
   | e
   | l
   | l
   | o
]]
]==]
,
{
ABC = {
a = 'Hello',
b = 1.0,
c = {'1', '2', '3'},
d = { x = 2, y = 4, [5] = 5 },
e = true,
[10] = [[
   | H
   | e
   | l
   | l
   | o
]]
  }
}
)

print('test ok!')
