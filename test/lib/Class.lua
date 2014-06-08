-- Helper module to provide a simple way to create a new class with optional
-- parent classes for inheritance.
--
-- It assumes that an index "new" exists on the class so it can be called
-- during initialization as a constructor.
--
-- Example:
--
--     Klass = Class()
--
--     function Klass:new(var)
--       self.var = var
--       print("In constructor")
--     end
--
--     function Klass:method(args)
--       print("In method")
--       -- can refer to self and super, etc.
--     end
--
--     k = Klass(4)
--     k:method()
--
--     -- etc...

Class = function(parent)
  local klass = {}
  klass.super = parent
  klass.__index = klass

  setmetatable(klass, {
    __index = parent,
    __call = function(cls, ...)
      local self = setmetatable({}, klass)
      cls.new(self, ...)
      return self
    end
  })

  return klass
end

return Class
