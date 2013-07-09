
function playSound(src)
	if not sound[src]:isStopped() then
		sound[src]:rewind()
	end
	love.audio.play(sound[src])
end

-- Create a new class that inherits from a base class taken from
-- http://lua-users.org/wiki/InheritanceTutorial
function inheritsFrom( baseClass )
    -- Create the table and metatable representing the class.
    local new_class = {}
    local class_mt = { __index = new_class }
    function new_class:create()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end
    if baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end
    return new_class
end


--[[
	TABLE SHOW taken from http://lua-users.org/wiki/TableSerialization
   Author: Julio Manuel Fernandez-Diaz
   Date:   January 12, 2007
   (For Lua 5.1)
   
   Modified slightly by RiciLake to avoid the unnecessary table traversal in tablecount()

   Formats tables with cycles recursively to any depth.
   The output is returned as a string.
   References to other tables are shown as values.
   Self references are indicated.

   The string returned is "Lua code", which can be procesed
   (in the case in which indent is composed by spaces or "--").
   Userdata and function keys and values are shown as strings,
   which logically are exactly not equivalent to the original code.

   This routine can serve for pretty formating tables with
   proper indentations, apart from printing them:

      print(table.show(t, "t"))   -- a typical use
   
   Heavily based on "Saving tables with cycles", PIL2, p. 113.

   Arguments:
      t is the table.
      name is the name of the table (optional)
      indent is a first indentation (optional).
--]]
function table.show(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   --[[ counts the number of elements in a table
   local function tablecount(t)
      local n = 0
      for _, _ in pairs(t) do n = n+1 end
      return n
   end
   ]]
   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
      local so = tostring(o)
      if type(o) == "function" then
         local info = debug.getinfo(o, "S")
         -- info.name is nil because o is not a calling level
         if info.what == "C" then
            return string.format("%q", so .. ", C function")
         else 
            -- the information is defined through lines
            return string.format("%q", so .. ", defined in (" ..
                info.linedefined .. "-" .. info.lastlinedefined ..
                ")" .. info.source)
         end
      elseif type(o) == "number" or type(o) == "boolean" then
         return so
      else
         return string.format("%q", so)
      end
   end

   local function addtocart (value, name, indent, saved, field)
      indent = indent or ""
      saved = saved or {}
      field = field or name

      cart = cart .. indent .. field

      if type(value) ~= "table" then
         cart = cart .. " = " .. basicSerialize(value) .. ";\n"
      else
         if saved[value] then
            cart = cart .. " = {}; -- " .. saved[value] 
                        .. " (self reference)\n"
            autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
         else
            saved[value] = name
            --if tablecount(value) == 0 then
            if isemptytable(value) then
               cart = cart .. " = {};\n"
            else
               cart = cart .. " = {\n"
               for k, v in pairs(value) do
                  k = basicSerialize(k)
                  local fname = string.format("%s[%s]", name, k)
                  field = string.format("[%s]", k)
                  -- three spaces between levels
                  addtocart(v, fname, indent .. "   ", saved, field)
               end
               cart = cart .. indent .. "};\n"
            end
         end
      end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
      return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end


function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end


--- Tserial v1.5, a simple table serializer which turns tables into Lua script
-- @author Taehl (SelfMadeSpirit@gmail.com)
Tserial = {}
TSerial = Tserial	-- for backwards-compatibility

--- Serializes a table into a string, in form of Lua script.
-- @param t table to be serialized (may not contain any circular reference)
-- @param drop if true, unserializable types will be silently dropped instead of raising errors
-- if drop is a function, it will be called to serialize unsupported types
-- if drop is a table, it will be used as a serialization table (where {[value] = serial})
-- @param indent if true, output "human readable" mode with newlines and indentation (for debug)
-- @return string recreating given table
function Tserial.pack(t, drop, indent)
	assert(type(t) == "table", "Can only Tserial.pack tables.")
	local s, empty, indent = "{"..(indent and "\n" or ""), true, indent and math.max(type(indent)=="number" and indent or 0,0)
	local function proc(k,v, omitKey)	-- encode a key/value pair
		empty = nil	-- helps ensure empty tables return as "{}"
		local tk, tv, skip = type(k), type(v)
		if type(drop)=="table" and drop[k] then k = "["..drop[k].."]"
		elseif tk == "boolean" then k = k and "[true]" or "[false]"
		elseif tk == "string" then local f = string.format("%q",k) if f ~= '"'..k..'"' then k = '['..f..']' end
		elseif tk == "number" then k = "["..k.."]"
		elseif tk == "table" then k = "["..Tserial.pack(k, drop, indent and indent+1).."]"
		elseif type(drop) == "function" then k = "["..string.format("%q",drop(k)).."]"
		elseif drop then skip = true
		else error("Attempted to Tserial.pack a table with an invalid key: "..tostring(k))
		end
		if type(drop)=="table" and drop[v] then v = drop[v]
		elseif tv == "boolean" then v = v and "true" or "false"
		elseif tv == "string" then v = string.format("%q", v)
		elseif tv == "number" then	-- no change needed
		elseif tv == "table" then v = Tserial.pack(v, drop, indent and indent+1)
		elseif type(drop) == "function" then v = string.format("%q",drop(v))
		elseif drop then skip = true
		else error("Attempted to Tserial.pack a table with an invalid value: "..tostring(v))
		end
		if not skip then return string.rep("\t",indent or 0)..(omitKey and "" or k.."=")..v..","..(indent and "\n" or "") end
		return ""
	end
	local l=-1 repeat l=l+1 until t[l+1]==nil	-- #t "can" lie!
	for i=1,l do s = s..proc(i, t[i], true) end	-- use ordered values when possible for better string
	for k, v in pairs(t) do if not (type(k)=="number" and k<=l) then s = s..proc(k, v) end end
	if not empty then s = string.sub(s,1,string.len(s)-1) end
	if indent then s = string.sub(s,1,string.len(s)-1).."\n" end
	return s..string.rep("\t",(indent or 1)-1).."}"
end

--- Loads a table into memory from a string (like those output by Tserial.pack)
-- @param s a string of Lua defining a table, such as "{2,4,8,ex='ample'}"
-- @param safe if true, all extraneous parts of the string will be removed, leaving only a table (prevents running anomalous code when unpacking untrusted strings). Will also cause malformed tables to quietly return nil and an error message, instead of throwing an error (so your program can't be crashed with a bad string)
-- @return a table recreated from the given string.
function Tserial.unpack(s, safe)
	if safe then s = string.match(s, "(%b{})") end
	assert(type(s) == "string", "Can only Tserial.unpack strings.")
	local f, result = loadstring("Tserial.table="..s)
	if not safe then assert(f,result) elseif not f then return nil, result end
	result = f()
	local t = Tserial.table
	Tserial.table = nil
	return t, result
end