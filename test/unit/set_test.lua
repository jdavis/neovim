local Set = require "set"

--
-- Basic objects to populate the Set
--

local OBJ1 = {object = 1}
local OBJ2 = {object = 2}
local OBJ3 = {object = 3}


describe("Set helper class", function()
    describe("can add objects", function()

        it("should update the size on add", function()
            set = Set()

            set:add(OBJ1)
            assert.are.same(set:size(), 1)

            set:add(OBJ2)
            assert.are.same(set:size(), 2)
        end)
    end)

    describe("can remove objects", function()

        it("should update the size on remove", function()
            set = Set()
            set:add(OBJ1)
            set:add(OBJ2)

            set:remove(OBJ2)
            assert.are.same(set:size(), 1)

            set:remove(OBJ1)
            assert.are.same(set:size(), 0)
        end)
    end)

    describe("can union sets", function()
        it("should work with the empty set", function()
            empty = Set()

            expected = Set()
            set = Set()

            set:union(empty)

            assert.are.same(set, expected)

            set2 = Set()
            set2:add(OBJ1)

            set:union(set2)

            expected:add(OBJ1)

        end)
    end)

    describe("can take the diff of sets", function()
        pending("I'll do this later...")
    end)

    describe("can check if set contains an object", function()
        pending("I'll do this later...")
    end)

    describe("can iterate over the set", function()
        pending("I'll do this later...")
    end)
end)
