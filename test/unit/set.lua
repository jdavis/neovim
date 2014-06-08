local Set = require "test.lib.Set"

--
-- Basic objects to populate the Set
--

local OBJ1 = {object = 1}
local OBJ2 = {object = 2}
local OBJ3 = {object = 3}
local OBJ4 = {object = 4}


describe("Set helper class", function()
    local set

    before_each(function()
        set = Set()
    end)

    describe("can add objects", function()
        it("should not allow duplication", function()
            set:add(OBJ1)
            assert.are.same(1, set:size())

            set:add(OBJ1)
            assert.are.same(1, set:size())
        end)

        it("should update the size on add", function()
            set:add(OBJ1)
            assert.are.same(1, set:size())

            set:add(OBJ2)
            assert.are.same(2, set:size())
        end)
    end)

    describe("can remove objects", function()
        it("should update the size on remove", function()
            set:add(OBJ1)
            set:add(OBJ2)

            set:remove(OBJ2)
            assert.are.same(1, set:size())

            set:remove(OBJ1)
            assert.are.same(0, set:size())
        end)

        it("should not change removing invalid item", function()
            set:add(OBJ1)
            set:add(OBJ2)

            set:remove(OBJ2)
            assert.are.same(1, set:size())

            set:remove(OBJ2)
            assert.are.same(1, set:size())
        end)
    end)

    describe("can union sets", function()
        it("should union two empty sets", function()
            empty = Set()

            set:union(empty)

            expected = Set()
            assert.are.same(expected, set)
        end)

        it("should union one empty set", function()
            empty = Set()

            set:add(OBJ1)
            set:add(OBJ2)

            set:union(empty)

            expected = Set()
            expected:add(OBJ1)
            expected:add(OBJ2)

            assert.are.same(expected, set)
        end)

        it("should union two sets", function()
            second = Set()

            set:add(OBJ1)
            set:add(OBJ2)

            second:add(OBJ3)

            set:union(second)

            expected = Set()
            expected:add(OBJ1)
            expected:add(OBJ2)
            expected:add(OBJ3)

            assert.are.same(expected, set)
        end)
    end)

    describe("can union a table", function()
        it("should union one empty set and one empty table", function()
            empty = {}

            set:union_table(empty)

            expected = Set()
            assert.are.same(expected, set)
        end)

        it("should union one empty table", function()
            empty = {}

            set:add(OBJ1)
            set:add(OBJ2)

            set:union_table(empty)

            expected = Set()
            expected:add(OBJ1)
            expected:add(OBJ2)

            assert.are.same(expected, set)
        end)

        it("should union one table", function()
            tbl = {OBJ2, OBJ3}

            set:add(OBJ1)

            set:union_table(tbl)

            expected = Set()
            expected:add(OBJ1)
            expected:add(OBJ2)
            expected:add(OBJ3)

            assert.are.same(expected, set)
        end)
    end)

    describe("can take the diff of sets", function()
        it("should not alter when diffing empty", function()
            empty = Set()

            set:add(OBJ1)
            set:add(OBJ2)

            set:diff(empty)

            expected = Set()
            expected:add(OBJ1)
            expected:add(OBJ2)

            assert.are.same(expected, set)
        end)

        it("should be empty when diffing self", function()
            second = Set()

            set:add(OBJ1)
            set:add(OBJ2)

            second:add(OBJ1)
            second:add(OBJ2)

            set:diff(second)

            expected = Set()

            assert.are.same(expected, set)
        end)

        it("should diff two sets", function()
            second = Set()

            set:add(OBJ1)
            set:add(OBJ2)

            second:add(OBJ2)

            set:diff(second)

            expected = Set()
            expected:add(OBJ1)

            assert.are.same(expected, set)
        end)
    end)

    describe("can check if set contains an object", function()
        it("should contain added object", function()
            set:add(OBJ1)

            assert.is.truthy(set:contains(OBJ1))
        end)

        it("should not contain object", function()
            set:add(OBJ1)

            assert.is.falsy(set:contains(OBJ2))
        end)
    end)

    describe("can iterate over the set", function()
        it("shouldn't iterate over an empty set", function()
            local count = 0

            for k,v in set:iterator() do
                count = count + 1
            end

            assert.are.same(0, count)
        end)

        it("should iterate over all items in the set", function()
            set:add(OBJ1)
            set:add(OBJ2)
            set:add(OBJ3)
            set:add(OBJ4)

            set:remove(OBJ4)

            second = Set()

            for k,v in set:iterator() do
                second:add(v)
            end

            expected = Set()
            expected:add(OBJ1)
            expected:add(OBJ2)
            expected:add(OBJ3)

            assert.are.same(expected, set)
        end)
    end)

    describe("can convert to table", function()
        it("should return empty table", function()
            result = set:to_table()

            expected = {}
            assert.are.same(expected, result)
        end)

        it("should return table without gaps", function()
            set:add(OBJ1)
            set:add(OBJ2)
            set:add(OBJ3)

            set:remove(OBJ1)
            set:remove(OBJ3)

            result = set:to_table()

            expected = {OBJ2}
            assert.are.same(expected, result)
        end)
    end)
end)
