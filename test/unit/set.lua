-- a set class for fast union/diff, can always return a table with the lines
-- in the same relative order in which they were added by calling the
-- to_table method. It does this by keeping two lua tables that mirror each
-- other:
-- 1) index => item
-- 2) item => index

local Set = {}
Set.__index = Set

function Set:new(items)
    if type(items) == 'table' then
        local tempset = Set()
        tempset:union_table(items)
        self.tbl = tempset:raw_tbl()
        self.items = tempset:raw_items()
        self.nelem = tempset:size()
    else
        self.tbl = { }
        self.items = { }
        self.nelem = 0
    end
end

-- adds the argument Set to this Set
function Set:union(other)
    for e in other:iterator() do
        self:add(e)
    end
end

-- substracts the argument Set from this Set
function Set:union_table(t)
    for k, v in pairs(t) do
        self:add(v)
    end
end

function Set:diff(other)
    if other:size() > self:size() then
        -- this set is smaller than the other set
        for e in self:iterator() do
            if other:contains(e) then
                self:remove(e)
            end
        end
    else
        -- this set is larger than the other set
        for e in other:iterator() do
            if self.items[e] then
                self:remove(e)
            end
        end
    end
end

function Set:add(it)
    if not self:contains(it) then
        local idx = #self.tbl + 1
        self.tbl[idx] = it
        self.items[it] = idx
        self.nelem = self.nelem + 1
    end
end

function Set:remove(it)
    if self:contains(it) then
        local idx = self.items[it]
        self.tbl[idx] = nil
        self.items[it] = nil
        self.nelem = self.nelem - 1
    end
end

function Set:contains(it)
    return self.items[it] or false
end

function Set:size()
    return self.nelem
end

function Set:raw_tbl()
    return self.tbl
end

function Set:raw_items()
    return self.items
end

function Set:iterator()
    return pairs(self.items)
end

function Set:to_table()
    -- there might be gaps in @tbl, so we have to be careful and sort first
    local keys = {}
    local len = 1
    for idx, _ in pairs(self.tbl) do
        keys[len] = idx
        len = len + 1
    end

    table.sort(keys)

    local copy = {}
    local len = 1
    for _, idx in ipairs(keys) do
        copy[len] = self.tbl[idx]
        len = len + 1
    end

    return copy
end

Set = setmetatable(Set, {
    __call = function(cls, ...)
        local self = setmetatable({}, Set)
        cls.new(self, ...)
        return self
    end
})

return Set
