local cimport, internalize, eq, neq, ffi, lib, cstr, to_cstr
do
  local _obj_0 = require('test.lib.helpers')
  cimport, internalize, eq, neq, ffi, lib, cstr, to_cstr = _obj_0.cimport, _obj_0.internalize, _obj_0.eq, _obj_0.neq, _obj_0.ffi, _obj_0.lib, _obj_0.cstr, _obj_0.to_cstr
end
local garray = cimport('./src/nvim/garray.h')
local NULL = ffi.cast('void*', 0)
local ga_len
ga_len = function(garr)
  return garr[0].ga_len
end
local ga_maxlen
ga_maxlen = function(garr)
  return garr[0].ga_maxlen
end
local ga_itemsize
ga_itemsize = function(garr)
  return garr[0].ga_itemsize
end
local ga_growsize
ga_growsize = function(garr)
  return garr[0].ga_growsize
end
local ga_data
ga_data = function(garr)
  return garr[0].ga_data
end
local ga_size
ga_size = function(garr)
  return ga_len(garr) * ga_itemsize(garr)
end
local ga_maxsize
ga_maxsize = function(garr)
  return ga_maxlen(garr) * ga_itemsize(garr)
end
local ga_data_as_bytes
ga_data_as_bytes = function(garr)
  return ffi.cast('uint8_t *', ga_data(garr))
end
local ga_data_as_strings
ga_data_as_strings = function(garr)
  return ffi.cast('char **', ga_data(garr))
end
local ga_data_as_ints
ga_data_as_ints = function(garr)
  return ffi.cast('int *', ga_data(garr))
end
local ga_init
ga_init = function(garr, itemsize, growsize)
  return garray.ga_init(garr, itemsize, growsize)
end
local ga_clear
ga_clear = function(garr)
  return garray.ga_clear(garr)
end
local ga_clear_strings
ga_clear_strings = function(garr)
  assert.is_true(ga_itemsize(garr) == ffi.sizeof('char *'))
  return garray.ga_clear_strings(garr)
end
local ga_grow
ga_grow = function(garr, n)
  return garray.ga_grow(garr, n)
end
local ga_concat
ga_concat = function(garr, str)
  return garray.ga_concat(garr, to_cstr(str))
end
local ga_append
ga_append = function(garr, b)
  if type(b) == 'string' then
    return garray.ga_append(garr, string.byte(b))
  else
    return garray.ga_append(garr, b)
  end
end
local ga_concat_strings
ga_concat_strings = function(garr)
  return internalize(garray.ga_concat_strings(garr))
end
local ga_concat_strings_sep
ga_concat_strings_sep = function(garr, sep)
  return internalize(garray.ga_concat_strings_sep(garr, to_cstr(sep)))
end
local ga_remove_duplicate_strings
ga_remove_duplicate_strings = function(garr)
  return garray.ga_remove_duplicate_strings(garr)
end
local ga_set_len
ga_set_len = function(garr, len)
  assert.is_true(len <= ga_maxlen(garr))
  garr[0].ga_len = len
end
local ga_inc_len
ga_inc_len = function(garr, by)
  return ga_set_len(garr, ga_len(garr) + 1)
end
local ga_append_int
ga_append_int = function(garr, it)
  assert.is_true(ga_itemsize(garr) == ffi.sizeof('int'))
  ga_grow(garr, 1)
  local data = ga_data_as_ints(garr)
  data[ga_len(garr)] = it
  return ga_inc_len(garr, 1)
end
local ga_append_string
ga_append_string = function(garr, it)
  assert.is_true(ga_itemsize(garr) == ffi.sizeof('char *'))
  local mem = ffi.C.malloc(string.len(it) + 1)
  ffi.copy(mem, it)
  ga_grow(garr, 1)
  local data = ga_data_as_strings(garr)
  data[ga_len(garr)] = mem
  return ga_inc_len(garr, 1)
end
local ga_append_strings
ga_append_strings = function(garr, ...)
  local prevlen = ga_len(garr)
  local len = select('#', ...)
  for i = 1, len do
    ga_append_string(garr, select(i, ...))
  end
  return eq(prevlen + len, ga_len(garr))
end
local ga_append_ints
ga_append_ints = function(garr, ...)
  local prevlen = ga_len(garr)
  local len = select('#', ...)
  for i = 1, len do
    ga_append_int(garr, select(i, ...))
  end
  return eq(prevlen + len, ga_len(garr))
end
local garray_ctype = ffi.typeof('garray_T[1]')
local new_garray
new_garray = function()
  local garr = garray_ctype()
  return ffi.gc(garr, ga_clear)
end
local new_string_garray
new_string_garray = function()
  local garr = garray_ctype()
  ga_init(garr, ffi.sizeof("char_u *"), 1)
  return ffi.gc(garr, ga_clear_strings)
end
local randomByte
randomByte = function()
  return ffi.cast('uint8_t', math.random(0, 255))
end
local ga_scramble
ga_scramble = function(garr)
  local size, bytes = ga_size(garr), ga_data_as_bytes(garr)
  for i = 0, size - 1 do
    bytes[i] = randomByte()
  end
end
return describe('garray', function()
  local itemsize = 14
  local growsize = 95
  describe('ga_init', function()
    return it('initializes the values of the garray', function()
      local garr = new_garray()
      ga_init(garr, itemsize, growsize)
      eq(0, ga_len(garr))
      eq(0, ga_maxlen(garr))
      eq(growsize, ga_growsize(garr))
      eq(itemsize, ga_itemsize(garr))
      return eq(NULL, ga_data(garr))
    end)
  end)
  describe('ga_grow', function()
    local new_and_grow
    new_and_grow = function(itemsize, growsize, req)
      local garr = new_garray()
      ga_init(garr, itemsize, growsize)
      eq(0, ga_size(garr))
      eq(NULL, ga_data(garr))
      ga_grow(garr, req)
      return garr
    end
    it('grows by growsize items if num < growsize', function()
      itemsize = 16
      growsize = 4
      local grow_by = growsize - 1
      local garr = new_and_grow(itemsize, growsize, grow_by)
      neq(NULL, ga_data(garr))
      return eq(growsize, ga_maxlen(garr))
    end)
    it('grows by num items if num > growsize', function()
      itemsize = 16
      growsize = 4
      local grow_by = growsize + 1
      local garr = new_and_grow(itemsize, growsize, grow_by)
      neq(NULL, ga_data(garr))
      return eq(grow_by, ga_maxlen(garr))
    end)
    return it('does not grow when nothing is requested', function()
      local garr = new_and_grow(16, 4, 0)
      eq(NULL, ga_data(garr))
      return eq(0, ga_maxlen(garr))
    end)
  end)
  describe('ga_clear', function()
    return it('clears an already allocated array', function()
      local garr = garray_ctype()
      ga_init(garr, itemsize, growsize)
      ga_grow(garr, 4)
      ga_set_len(garr, 4)
      ga_scramble(garr)
      ga_clear(garr)
      eq(NULL, ga_data(garr))
      eq(0, ga_maxlen(garr))
      return eq(0, ga_len(garr))
    end)
  end)
  describe('ga_append', function()
    it('can append bytes', function()
      local garr = new_garray()
      ga_init(garr, ffi.sizeof("uint8_t"), 1)
      ga_append(garr, 'h')
      ga_append(garr, 'e')
      ga_append(garr, 'l')
      ga_append(garr, 'l')
      ga_append(garr, 'o')
      ga_append(garr, 0)
      local bytes = ga_data_as_bytes(garr)
      return eq('hello', ffi.string(bytes))
    end)
    it('can append integers', function()
      local garr = new_garray()
      ga_init(garr, ffi.sizeof("int"), 1)
      local input = {
        -20,
        94,
        867615,
        90927,
        86
      }
      ga_append_ints(garr, unpack(input))
      local ints = ga_data_as_ints(garr)
      for i = 0, #input - 1 do
        eq(input[i + 1], ints[i])
      end
    end)
    return it('can append strings to a growing array of strings', function()
      local garr = new_string_garray()
      local input = {
        "some",
        "str",
        "\r\n\r●●●●●●,,,",
        "hmm",
        "got it"
      }
      ga_append_strings(garr, unpack(input))
      local strings = ga_data_as_strings(garr)
      for i = 0, #input - 1 do
        eq(input[i + 1], ffi.string(strings[i]))
      end
    end)
  end)
  describe('ga_concat', function()
    return it('concatenates the parameter to the growing byte array', function()
      local garr = new_garray()
      ga_init(garr, ffi.sizeof("char"), 1)
      local str = "ohwell●●"
      local loop = 5
      for i = 1, loop do
        ga_concat(garr, str)
      end
      ga_append(garr, 0)
      local result = ffi.string(ga_data_as_bytes(garr))
      return eq(string.rep(str, loop), result)
    end)
  end)
  local test_concat_fn
  test_concat_fn = function(input, fn, sep)
    local garr = new_string_garray()
    ga_append_strings(garr, unpack(input))
    if sep == nil then
      return eq(table.concat(input, ','), fn(garr))
    else
      return eq(table.concat(input, sep), fn(garr, sep))
    end
  end
  describe('ga_concat_strings', function()
    it('returns an empty string when concatenating an empty array', function()
      return test_concat_fn({ }, ga_concat_strings)
    end)
    return it('can concatenate a non-empty array', function()
      return test_concat_fn({
        'oh',
        'my',
        'neovim'
      }, ga_concat_strings)
    end)
  end)
  describe('ga_concat_strings_sep', function()
    it('returns an empty string when concatenating an empty array', function()
      return test_concat_fn({ }, ga_concat_strings_sep, '---')
    end)
    return it('can concatenate a non-empty array', function()
      local sep = '-●●-'
      return test_concat_fn({
        'oh',
        'my',
        'neovim'
      }, ga_concat_strings_sep, sep)
    end)
  end)
  return describe('ga_remove_duplicate_strings', function()
    return it('sorts and removes duplicate strings', function()
      local garr = new_string_garray()
      local input = {
        'ccc',
        'aaa',
        'bbb',
        'ddd●●',
        'aaa',
        'bbb',
        'ccc',
        'ccc',
        'ddd●●'
      }
      local sorted_dedup_input = {
        'aaa',
        'bbb',
        'ccc',
        'ddd●●'
      }
      ga_append_strings(garr, unpack(input))
      ga_remove_duplicate_strings(garr)
      eq(#sorted_dedup_input, ga_len(garr))
      local strings = ga_data_as_strings(garr)
      for i = 0, #sorted_dedup_input - 1 do
        eq(sorted_dedup_input[i + 1], ffi.string(strings[i]))
      end
    end)
  end)
end)
