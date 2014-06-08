local cimport, internalize, eq, ffi, lib, cstr, to_cstr
do
  local _obj_0 = require('test.lib.helpers')
  cimport, internalize, eq, ffi, lib, cstr, to_cstr = _obj_0.cimport, _obj_0.internalize, _obj_0.eq, _obj_0.ffi, _obj_0.lib, _obj_0.cstr, _obj_0.to_cstr
end
require('lfs')
local env = cimport('./src/nvim/os/os.h')
local NULL = ffi.cast('void*', 0)
return describe('env function', function()
  local os_setenv
  os_setenv = function(name, value, override)
    return env.os_setenv((to_cstr(name)), (to_cstr(value)), override)
  end
  local os_getenv
  os_getenv = function(name)
    local rval = env.os_getenv((to_cstr(name)))
    if rval ~= NULL then
      return ffi.string(rval)
    else
      return NULL
    end
  end
  describe('os_setenv', function()
    local OK = 0
    it('sets an env variable and returns OK', function()
      local name = 'NEOVIM_UNIT_TEST_SETENV_1N'
      local value = 'NEOVIM_UNIT_TEST_SETENV_1V'
      eq(nil, os.getenv(name))
      eq(OK, (os_setenv(name, value, 1)))
      return eq(value, os.getenv(name))
    end)
    return it("dosn't overwrite an env variable if overwrite is 0", function()
      local name = 'NEOVIM_UNIT_TEST_SETENV_2N'
      local value = 'NEOVIM_UNIT_TEST_SETENV_2V'
      local value_updated = 'NEOVIM_UNIT_TEST_SETENV_2V_UPDATED'
      eq(OK, (os_setenv(name, value, 0)))
      eq(value, os.getenv(name))
      eq(OK, (os_setenv(name, value_updated, 0)))
      return eq(value, os.getenv(name))
    end)
  end)
  describe('os_getenv', function()
    it('reads an env variable', function()
      local name = 'NEOVIM_UNIT_TEST_GETENV_1N'
      local value = 'NEOVIM_UNIT_TEST_GETENV_1V'
      eq(NULL, os_getenv(name))
      os_setenv(name, value, 1)
      return eq(value, os_getenv(name))
    end)
    return it('returns NULL if the env variable is not found', function()
      local name = 'NEOVIM_UNIT_TEST_GETENV_NOTFOUND'
      return eq(NULL, os_getenv(name))
    end)
  end)
  describe('os_getenvname_at_index', function()
    it('returns names of environment variables', function()
      local test_name = 'NEOVIM_UNIT_TEST_GETENVNAME_AT_INDEX_1N'
      local test_value = 'NEOVIM_UNIT_TEST_GETENVNAME_AT_INDEX_1V'
      os_setenv(test_name, test_value, 1)
      local i = 0
      local names = { }
      local found_name = false
      local name = env.os_getenvname_at_index(i)
      while name ~= NULL do
        table.insert(names, ffi.string(name))
        if (ffi.string(name)) == test_name then
          found_name = true
        end
        i = i + 1
        name = env.os_getenvname_at_index(i)
      end
      eq(true, (table.getn(names)) > 0)
      return eq(true, found_name)
    end)
    return it('returns NULL if the index is out of bounds', function()
      local huge = ffi.new('size_t', 10000)
      local maxuint32 = ffi.new('size_t', 4294967295)
      eq(NULL, env.os_getenvname_at_index(huge))
      eq(NULL, env.os_getenvname_at_index(maxuint32))
      if ffi.abi('64bit') then
        local maxuint64 = ffi.new('size_t', 18446744073709000000)
        return eq(NULL, env.os_getenvname_at_index(maxuint64))
      end
    end)
  end)
  describe('os_get_pid', function()
    return it('returns the process ID', function()
      local stat_file = io.open('/proc/self/stat')
      if stat_file then
        local stat_str = stat_file:read('*l')
        stat_file:close()
        local pid = tonumber((stat_str:match('%d+')))
        return eq(pid, tonumber(env.os_get_pid()))
      else
        return eq(true, (env.os_get_pid() > 0))
      end
    end)
  end)
  return describe('os_get_hostname', function()
    return it('returns the hostname', function()
      local handle = io.popen('hostname')
      local hostname = handle:read('*l')
      handle:close()
      local hostname_buf = cstr(255, '')
      env.os_get_hostname(hostname_buf, 255)
      return eq(hostname, (ffi.string(hostname_buf)))
    end)
  end)
end)
