package.cpath = package.cpath .. [[;.\..\bin\Debug\?.dll]]

local lni = require 'lni-c'

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
			assert(v == b[k], v)
		end
	end
end

local function TEST(script, t)
	local r = lni(script)
	EQUAL(r, t)
	EQUAL(t, r)
end

TEST(
[==[
[ABC]  
a = 'Hello'  
b = 1.0  
c = {'1', '2', '3'}  
'd' = {  
  x = 2,  
  y = 4,  
}  
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
d = { x = 2, y = 4 },  
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

TEST([==[
[[A]]  
a = 1
[[A]]  
a = 2 
]==]
,
{
 A = {{a = 1}, {a = 2}}  
}
)

TEST([==[
[default] a = 1 
[A] b = 0  
]==]
,
{
 A = { a = 1, b = 0 }  
}
)

TEST([==[
[default] a = 1 
[[A]] b = 0  
]==]
,
{
 A = {{ b = 0 }}  
}
)

TEST([==[
[enum]  
YES = 1  
NO = 0  
[A]  
a = YES  
b = NO  
]==]
,
{
 A = { a = 1, b = 0 }  
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
  A = { a = 1, b = 2 }
}
)

print('test ok!')
