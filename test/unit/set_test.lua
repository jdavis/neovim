local Set = require "set"
local inspect = require "inspect"

--
-- Basic objects to populate the Set
--

local OBJ1 = {object = 1}
local OBJ2 = {object = 2}
local OBJ3 = {object = 3}


describe("Set helper class", function()
    local set

    before_each(function()
        set = Set()
    end)

    describe("can add objects", function()
        it("should not allow duplication", function()
            set:add(OBJ1)
            assert.are.same(set:size(), 1)

            set:add(OBJ1)
            assert.are.same(set:size(), 1)
        end)

        it("should update the size on add", function()
            set:add(OBJ1)
            assert.are.same(set:size(), 1)

            set:add(OBJ2)
            assert.are.same(set:size(), 2)
        end)
    end)

    describe("can remove objects", function()
        it("should update the size on remove", function()
            set:add(OBJ1)
            set:add(OBJ2)

            set:remove(OBJ2)
            assert.are.same(set:size(), 1)

            set:remove(OBJ1)
            assert.are.same(set:size(), 0)
        end)

        it("should not change removing invalid item", function()
            set:add(OBJ1)
            set:add(OBJ2)

            set:remove(OBJ2)
            assert.are.same(set:size(), 1)

            set:remove(OBJ2)
            assert.are.same(set:size(), 1)
        end)
    end)

    describe("can union sets", function()
        it("should union two empty sets", function()
            empty = Set()

            set:union(empty)

            expected = Set()
            assert.are.same(set, expected)
        end)

        it("should union one empty set", function()
            empty = Set()

            set:add(OBJ1)
            set:add(OBJ2)

            set:union(empty)

            expected = Set()
            expected:add(OBJ1)
            expected:add(OBJ2)

            assert.are.same(set, expected)
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

            assert.are.same(set, expected)
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

            assert.are.same(set, expected)
        end)

        it("should be empty when diffing self", function()
            second = Set()

            set:add(OBJ1)
            set:add(OBJ2)

            second:add(OBJ1)
            second:add(OBJ2)

            set:diff(second)

            expected = Set()

            assert.are.same(set, expected)
        end)

        it("should diff two sets", function()
            second = Set()

            set:add(OBJ1)
            set:add(OBJ2)

            second:add(OBJ2)

            set:diff(second)

            expected = Set()
            expected:add(OBJ1)

            assert.are.same(set, expected)
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
        pending("I'll do this later...")
    end)
end)
