local Set = {}

Set.__init = function(self)
end

function Set:union(other)
end

function Set:union_table(t)
end

function Set:diff(other)
end

function Set:add(it)
end

function Set:remove(it)
end

function Set:contains(it)
    return true
end

function Set:size()
    return 0
end

function Set:raw_tbl()
    return {}
end

function Set:raw_items()
    return {}
end

function Set:iterator()
    return {}
end

function Set:to_table()
    return {}
end

Set = setmetatable(Set, {
    __index = Set,
    __call = Set.new,
})

return Set
