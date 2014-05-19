LuaJIT FFI bindings for STFL
============================

STFL is a library which implements a curses-based widget set for text
terminals. The public STFL API is only 14 simple function calls big. A special
language (the Structured Terminal Forms Language) is used to describe STFL
GUIs. The language is designed to be easy and fast to write so an application
programmer does not need to spend ages fiddling around with the GUI and can
concentrate on the more interesting programming tasks.

STFL homepage: http://www.clifford.at/stfl/

Usage example
-------------

```lua
local stfl_interface = require("stfl")

local ffi = require("ffi")
local stfl_library = ffi.load("stfl")
local Stfl = stfl_interface.BytestringApi(stfl_library, "UTF8")

local form = Stfl.Form [[
  vbox @style_normal:bg=black,fg=white
    label .expand:h .tie:c style_normal:bg=blue
      text:'Example list'
    list
      style_focus:bg=white,fg=black,attr=bold
      listitem text:'Hello world'
      listitem text:'Hello world too'
      listitem text:'La langue française (Unicode displaying test)'
]]

os.setlocale("")
local event
while true do
  event = form:run(0)
  if event == "q" or event == "Q" then break end
end

Stfl.reset()

```

License
-------

The MIT license.

Part of bindings source (modified copy of stfl.h header file) is licensed
under LGPL3 (hence included LGPL3 text), but bindings source as a whole is
still licensed under the MIT license as permitted by sections 1 and 4 of
LGPL3.

