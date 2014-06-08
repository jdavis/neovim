local cimport, internalize, eq, ffi, lib, cstr
do
  local _obj_0 = require('test.lib.helpers')
  cimport, internalize, eq, ffi, lib, cstr = _obj_0.cimport, _obj_0.internalize, _obj_0.eq, _obj_0.ffi, _obj_0.lib, _obj_0.cstr
end
local users = cimport('./src/nvim/os/os.h', 'unistd.h')
local NULL = ffi.cast('void*', 0)
local OK = 1
local FAIL = 0
local garray_new
garray_new = function()
  return ffi.new('garray_T[1]')
end
local garray_get_len
garray_get_len = function(array)
  return array[0].ga_len
end
local garray_get_item
garray_get_item = function(array, index)
  return (ffi.cast('void **', array[0].ga_data))[index]
end
return describe('users function', function()
  local current_username = os.getenv('USER')
  describe('os_get_usernames', function()
    it('returns FAIL if called with NULL', function()
      return eq(FAIL, users.os_get_usernames(NULL))
    end)
    return it('fills the names garray with os usernames and returns OK', function()
      local ga_users = garray_new()
      eq(OK, users.os_get_usernames(ga_users))
      local user_count = garray_get_len(ga_users)
      assert.is_true(user_count > 0)
      local current_username_found = false
      for i = 0, user_count - 1 do
        local name = ffi.string((garray_get_item(ga_users, i)))
        if name == current_username then
          current_username_found = true
        end
      end
      return assert.is_true(current_username_found)
    end)
  end)
  describe('os_get_user_name', function()
    return it('should write the username into the buffer and return OK', function()
      local name_out = ffi.new('char[100]')
      eq(OK, users.os_get_user_name(name_out, 100))
      return eq(current_username, ffi.string(name_out))
    end)
  end)
  describe('os_get_uname', function()
    it('should write the username into the buffer and return OK', function()
      local name_out = ffi.new('char[100]')
      local user_id = lib.getuid()
      eq(OK, users.os_get_uname(user_id, name_out, 100))
      return eq(current_username, ffi.string(name_out))
    end)
    return it('should FAIL if the userid is not found', function()
      local name_out = ffi.new('char[100]')
      local user_id = 2342
      eq(FAIL, users.os_get_uname(user_id, name_out, 100))
      return eq('2342', ffi.string(name_out))
    end)
  end)
  return describe('os_get_user_directory', function()
    it('should return NULL if called with NULL', function()
      return eq(NULL, users.os_get_user_directory(NULL))
    end)
    it('should return $HOME for the current user', function()
      local home = os.getenv('HOME')
      return eq(home, ffi.string((users.os_get_user_directory(current_username))))
    end)
    return it('should return NULL if the user is not found', function()
      return eq(NULL, users.os_get_user_directory('neovim_user_not_found_test'))
    end)
  end)
end)
