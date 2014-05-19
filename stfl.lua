-- LuaJIT FFI bindings for STFL (Structured Terminal Forms Library) v0.22.
-- Copyright © 2014  Leonid Borisenko
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.
--
-- This software includes and uses modified copy of stfl.h header file from
-- STFL distribution as a covered work which is (along with its usage)
-- governed by (and covered by) GNU Lesser General Public License version 3,
-- or (at your option) any later version.
--
-- STFL is a library which implements a curses-based widget set for text
-- terminals. The public STFL API is only 14 simple function calls big.
-- A special language (the Structured Terminal Forms Language) is used to
-- describe STFL GUIs. The language is designed to be easy and fast to write
-- so an application programmer does not need to spend ages fiddling around
-- with the GUI and can concentrate on the more interesting programming tasks.
--
-- STFL homepage: <http://www.clifford.at/stfl/>

local ffi = require("ffi")

ffi.cdef [[
/*  stfl.h: The STFL C header file (modified)
 *  Copyright (C) 2014  Leonid Borisenko
 *
 *  2014-05-16 Leonid Borisenko
 *  * stfl.h: No C pre-processor tokens are allowed by LuaJIT 2.0.3 (except
 *  for '#pragma pack'), so they are commented out, along with the
 *  'extern "C"' guards.
 *
 *  stfl.h is free software; you can redistribute it and/or modify it under
 *  the terms of the GNU Lesser General Public License as published by the
 *  Free Software Foundation; either version 3 of the License, or (at your
 *  option) any later version.
 *
 *  stfl.h is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
 *  more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with stfl.h; if not, see <http://www.gnu.org/licenses>.
 *
 *  Here follows original stfl.h top comment (with copyright and permission
 *  notice).
/*
 *  STFL - The Structured Terminal Forms Language/Library
 *  Copyright (C) 2006, 2007  Clifford Wolf <clifford@clifford.at>
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *  
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *  
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 *  MA 02110-1301 USA
 *
 *  stfl.h: The STFL C header file
 */

//#ifndef STFL_H
//#define STFL_H 1

//#include <wchar.h>

//#ifdef  __cplusplus
//extern "C" {
//#endif

extern int stfl_api_allow_null_pointers;

struct stfl_form;
struct stfl_ipool;

extern struct stfl_form *stfl_create(const wchar_t *text);
extern void stfl_free(struct stfl_form *f);

extern const wchar_t *stfl_run(struct stfl_form *f, int timeout);
extern void stfl_reset();

extern const wchar_t * stfl_get(struct stfl_form *f, const wchar_t *name);
extern void stfl_set(struct stfl_form *f, const wchar_t *name, const wchar_t *value);

extern const wchar_t *stfl_get_focus(struct stfl_form *f);
extern void stfl_set_focus(struct stfl_form *f, const wchar_t *name);

extern const wchar_t *stfl_quote(const wchar_t *text);
extern const wchar_t *stfl_dump(struct stfl_form *f, const wchar_t *name, const wchar_t *prefix, int focus);

extern void stfl_modify(struct stfl_form *f, const wchar_t *name, const wchar_t *mode, const wchar_t *text);
extern const wchar_t *stfl_lookup(struct stfl_form *f, const wchar_t *path, const wchar_t *newname);

extern const wchar_t *stfl_error();
extern void stfl_error_action(const wchar_t *mode);

extern struct stfl_ipool *stfl_ipool_create(const char *code);
extern void *stfl_ipool_add(struct stfl_ipool *pool, void *data);
extern const wchar_t *stfl_ipool_towc(struct stfl_ipool *pool, const char *buf);
extern const char *stfl_ipool_fromwc(struct stfl_ipool *pool, const wchar_t *buf);
extern void stfl_ipool_flush(struct stfl_ipool *pool);
extern void stfl_ipool_destroy(struct stfl_ipool *pool);

//#ifdef __cplusplus
//}
//#endif

//#endif
]] -- ffi.cdef [[ stfl.h ]]

local ApiMetatable = {}
local Api = setmetatable({}, ApiMetatable)

function ApiMetatable:__call (stfl_clib)
  local stfl_api = self.StandaloneFunctions(stfl_clib)

  stfl_api.Form = self.FormMetatype(stfl_clib)
  stfl_api.Ipool = self.IpoolMetatype(stfl_clib)

  return stfl_api
end -- function ApiMetatable:__call

local BytestringApiMetatable = {}
local BytestringApi = setmetatable({}, BytestringApiMetatable)

function BytestringApiMetatable:__call (stfl_api, encoding)
  if type(stfl_api) == "userdata" then stfl_api = Api(stfl_api) end

  local ipool = stfl_api.Ipool(encoding)
  local stfl_bytestring_api = self.StandaloneFunctions(stfl_api, ipool)

  stfl_bytestring_api.Form = self.Form(stfl_api, ipool)
  stfl_bytestring_api.Ipool = stfl_api.Ipool

  return stfl_bytestring_api
end -- function BytestringApiMetatable:__call

function Api.StandaloneFunctions (stfl_clib)
  return {
    error = function () return stfl_clib.stfl_error() end,
    error_action = function (mode) stfl_clib.stfl_error_action(mode) end,
    quote = function (text) return stfl_clib.stfl_quote(text) end,
    reset = function () stfl_clib.stfl_reset() end,
  }
end -- function Api.StandloneFunctions

function BytestringApi.StandaloneFunctions (stfl_api, ipool)
  return {
    error = function ()
      ipool:flush()
      return ffi.string(ipool:fromwc(stfl_api.error()))
    end,
    error_action = function (mode)
      ipool:flush()
      stfl_api.error_action(ipool:towc(mode))
    end,
    quote = function (text)
      ipool:flush()
      local quoted = stfl_api.quote(ipool:towc(text))
      return ffi.string(ipool:fromwc(quoted))
    end,
    reset = stfl_api.reset,
  }
end -- function BytestringApi.StandaloneFunctions

local Form = {}

function Form:run (timeout)
  return self.clib.stfl_run(self, timeout)
end

function Form:get (name)
  return self.clib.stfl_get(self, name)
end

function Form:set (name, value)
  self.clib.stfl_set(self, name, value)
end

function Form:get_focus ()
  return self.clib.stfl_get_focus(self)
end

function Form:set_focus (name)
  self.clib.stfl_set_focus(self, name)
end

function Form:dump (name, prefix, focus)
  return self.clib.stfl_dump(self, name, prefix, focus)
end

function Form:modify (name, mode, text)
  self.clib.stfl_modify(self, name, mode, text)
end

function Form:lookup (path, newname)
  return self.clib.stfl_lookup(self, path, newname)
end

function Api.FormMetatype (stfl_clib)
  return ffi.metatype("struct stfl_form", {
    __index = setmetatable({clib = stfl_clib}, {__index = Form}),
    __new = function (ctype, text)
      return ffi.gc(
        ctype.clib.stfl_create(text),
        ctype.clib.stfl_free
      )
    end,
  })
end -- function Api.FormMetatype

local BsApiForm = {}

function BytestringApi.Form (stfl_api, ipool)
  return function (text)
    ipool:flush()
    return setmetatable(
      {form = stfl_api.Form(ipool:towc(text)), ipool=ipool},
      {__index = BsApiForm}
    )
  end
end -- function BytestringApi.Form

function BsApiForm:run (timeout)
  local event = self.form:run(timeout)
  if event ~= nil then
    self.ipool:flush()
    return ffi.string(self.ipool:fromwc(event))
  end
end -- function BsApiForm:run

function BsApiForm:get (name)
  self.ipool:flush()
  local value = self.form:get(self.ipool:towc(name))
  if value ~= nil then return ffi.string(self.ipool:fromwc(value)) end
end -- function BsApiForm:get

function BsApiForm:set (name, value)
  self.ipool:flush()
  self.form:set(self.ipool:towc(name), self.ipool:towc(value))
end -- function BsApiForm:set

function BsApiForm:get_focus ()
  local focused = self.form:get_focus()
  if focused ~= nil then
    self.ipool:flush()
    return ffi.string(self.ipool:fromwc(focused))
  end
end -- function BsApiForm:get_focus

function BsApiForm:set_focus (name)
  self.ipool:flush()
  self.form:set_focus(self.ipool:towc(name))
end -- functin BsApiForm:set_focus

function BsApiForm:dump (name, prefix, focus)
  self.ipool:flush()
  local dump = self.form:dump(
    self.ipool:towc(name),
    self.ipool:towc(prefix),
    focus
  )
  if dump ~= nil then return ffi.string(self.ipool:fromwc(dump)) end
end -- function BsApiForm:dump

function BsApiForm:modify (name, mode, text)
  self.ipool:flush()
  self.form:modify(
    self.ipool:towc(name),
    self.ipool:towc(mode),
    self.ipool:towc(text)
  )
end -- function BsApiForm:modify

function BsApiForm:lookup (path, newname)
  self.ipool:flush()
  local result = self.form:lookup(
    self.ipool:towc(path),
    self.ipool:towc(newname)
  )
  if result ~= nil then return ffi.string(self.ipool:fromwc(result)) end
end -- function BsApiForm:lookup

local Ipool = {}

function Ipool:add (data)
  self.clib.stfl_ipool_add(self, data)
end

function Ipool:towc (str)
  return self.clib.stfl_ipool_towc(self, str)
end

function Ipool:fromwc (buf)
  return self.clib.stfl_ipool_fromwc(self, buf)
end

function Ipool:flush ()
  self.clib.stfl_ipool_flush(self)
end

function Api.IpoolMetatype (stfl_clib)
  return ffi.metatype("struct stfl_ipool", {
    __index = setmetatable({clib = stfl_clib}, {__index = Ipool}),
    __new = function (ctype, code)
      return ffi.gc(
        ctype.clib.stfl_ipool_create(code),
        ctype.clib.stfl_ipool_destroy
      )
    end,
  })
end -- local function Api.IpoolMetatype

return {
  Api = Api,
  BytestringApi = BytestringApi,
}

