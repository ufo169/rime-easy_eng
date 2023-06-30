local user_data_dir = string.gsub(rime_api:get_user_data_dir(),"/","//")
local shared_data_dir = string.gsub(rime_api:get_shared_data_dir(),"/","//")
local dict_name = "/en_dicts/en_custom.dict.yaml"

local dict_dir = nil -- 初始化变量
if (io.open(user_data_dir..dict_name,"r")  )then -- 如果用户文件夹中找到了dict_name指向的词库文件，则将文件目录赋值给dict_dir
 dict_dir = user_data_dir..dict_name
else
 if(io.open(shared_data_dir..dict_name,"r"))then -- 如果用户文件夹中没找到dict_name指向的词库文件，但是程序文件夹中找到了，则将文件目录赋值给dict_dir
 dict_dir = shared_data_dir..dict_name
 else return
 end
end
local function user_dict_exists_(str,dir) -- 输入字符串和文件路径，在路径指向文件中逐行查找完全对应的字符串，如果已存在则返回true，适用于小狼毫判断词条是否已经存在
 local file = io.open(dir, "r")
 for line in file:lines() do
  if line == str then
   file:close()
   return true
  end
 end
 file:close()
 return false
end
return function (input,seg)
 if(input:sub(-1)=="`" and input~="`")then -- 输入末尾必须是`，并且排除只包含`的情况。
  local inp = " " .. input:sub(1,-2):gsub("|"," ")  -- -3对应两个末尾符号,-2对应一个
  local unconfirm = inp.."\t"..inp:gsub("[^%a]+",""):lower().."\t100000"
  if(user_dict_exists_(unconfirm,dict_dir))then
   local file = io.open(dict_dir, "r+")
   local content = file:read("*all")
   file:close()
   content = content:gsub("\n"..unconfirm:gsub("([%%%(%)%[%]%-*+?%.%^])", "%%%1"), "")
   file = io.open(dict_dir, "w+")
   file:write(content)
   file:close()
   yield(Candidate("en_custom",seg.start,seg._end,inp," 词已删 再输`可重添"))
  else
   local file = io.open(dict_dir,"a")
   file:write("\n"..unconfirm):close()
   yield(Candidate("en_custom",seg.start,seg._end,inp," 已保存为用户词"))
  end
 end
end