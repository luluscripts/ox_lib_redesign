
---@class Array<T> : OxClass, { [number]: T }
lib.array = lib.class('Array')

local table_unpack = table.unpack
local table_remove = table.remove
local table_clone = table.clone
local table_concat = table.concat
local table_type = table.type

---@alias ArrayLike<T> Array | { [number]: T }

---@private
function lib.array:constructor(...)
    local arr = { ... }

    for i = 1, #arr do
        self[i] = arr[i]
    end
end

---@private
function lib.array:__newindex(index, value)
    if type(index) ~= 'number' then error(("Cannot insert non-number index '%s' into an array."):format(index)) end

    rawset(self, index, value)
end

---@param iter table | function | string
---@return Array
function lib.array:from(iter)
    local iterType = type(iter)

    if iterType == 'table' then
        return lib.array:new(table_unpack(iter))
    end

    if iterType == 'string' then
        return lib.array:new(string.strsplit('', iter))
    end

    if iterType == 'function' then
        local arr = lib.array:new()
        local length = 0

        for value in iter do
            length += 1
            arr[length] = value
        end

        return arr
    end

    error(('Array.from argument was not a valid iterable value (received %s)'):format(iterType))
end

---@param index number
---@return unknown
function lib.array:at(index)
    if index < 0 then
        index = #self + index + 1
    end

    return self[index]
end

---@param ... ArrayLike
function lib.array:merge(...)
    local newArr = table_clone(self)
    local length = #self
    local arrays = { ... }

    for i = 1, #arrays do
        local arr = arrays[i]

        for j = 1, #arr do
            length += 1
            newArr[length] = arr[j]
        end
    end

    return lib.array:new(table_unpack(newArr))
end

---@param testFn fun(element: unknown): boolean
function lib.array:every(testFn)
    for i = 1, #self do
        if not testFn(self[i]) then
            return false
        end
    end

    return true
end

---@param value any
---@param start? number
---@param endIndex? number
function lib.array:fill(value, start, endIndex)
    local length = #self
    start = start or 1
    endIndex = endIndex or length

    if start < 1 then start = 1 end
    if endIndex > length then endIndex = length end

    for i = start, endIndex do
        self[i] = value
    end

    return self
end

---@param testFn fun(element: unknown): boolean
function lib.array:filter(testFn)
    local newArr = {}
    local length = 0

    for i = 1, #self do
        local element = self[i]

        if testFn(element) then
            length += 1
            newArr[length] = element
        end
    end

    return lib.array:new(table_unpack(newArr))
end

---@param testFn fun(element: unknown): boolean
---@param last? boolean
function lib.array:find(testFn, last)
    local a = last and #self or 1
    local b = last and 1 or #self
    local c = last and -1 or 1

    for i = a, b, c do
        local element = self[i]

        if testFn(element) then
            return element
        end
    end
end

---@param testFn fun(element: unknown): boolean
---@param last? boolean
function lib.array:findIndex(testFn, last)
    local a = last and #self or 1
    local b = last and 1 or #self
    local c = last and -1 or 1

    for i = a, b, c do
        local element = self[i]

        if testFn(element) then
            return i
        end
    end
end

---@param value unknown
---@param last? boolean
function lib.array:indexOf(value, last)
    local a = last and #self or 1
    local b = last and 1 or #self
    local c = last and -1 or 1

    for i = a, b, c do
        local element = self[i]

        if element == value then
            return i
        end
    end
end

---@param cb fun(element: unknown)
function lib.array:forEach(cb)
    for i = 1, #self do
        cb(self[i])
    end
end

---@param element unknown The value to find in the array.
---@param fromIndex? number The position in the array to begin searching from.
function lib.array:includes(element, fromIndex)
    for i = (fromIndex or 1), #self do
        if self[i] == element then return true end
    end

    return false
end

---@param seperator? string
function lib.array:join(seperator)
    return table_concat(self, seperator or ',')
end

---@param cb fun(element: unknown, index: number, array: self): unknown
function lib.array:map(cb)
    local arr = {}

    for i = 1, #self do
        arr[i] = cb(self[i], i, self)
    end

    return lib.array:new(table_unpack(arr))
end

function lib.array:pop()
    return table_remove(self)
end

---@param ... any
function lib.array:push(...)
    local elements = { ... }
    local length = #self

    for i = 1, #elements do
        length += 1
        self[length] = elements[i]
    end

    return length
end

---@generic T
---@param reducer fun(accumulator: T, currentValue: T, index?: number): T
---@param initialValue? T
---@param reverse? boolean Iterate over the array from right-to-left.
---@return T
function lib.array:reduce(reducer, initialValue, reverse)
    local length = #self
    local initialIndex = initialValue and 1 or 2
    local accumulator = initialValue or self[1]

    if reverse then
        for i = initialIndex, length do
            local index = length - i + initialIndex
            accumulator = reducer(accumulator, self[index], index)
        end
    else
        for i = initialIndex, length do
            accumulator = reducer(accumulator, self[i], i)
        end
    end

    return accumulator
end

function lib.array:reverse()
    local i, j = 1, #self

    while i < j do
        self[i], self[j] = self[j], self[i]
        i += 1
        j -= 1
    end

    return self
end

function lib.array:shift()
    return table_remove(self, 1)
end

---@param start? number
---@param finish? number
function lib.array:slice(start, finish)
    local length = #self
    start = start or 1
    finish = finish or length

    if start < 0 then start = length + start + 1 end
    if finish < 0 then finish = length + finish + 1 end
    if start < 1 then start = 1 end
    if finish > length then finish = length end

    local arr = lib.array:new()
    local index = 0

    for i = start, finish do
        index += 1
        arr[index] = self[i]
    end

    return arr
end

function lib.array:toReversed()
    local reversed = lib.array:new()

    for i = #self, 1, -1 do
        reversed:push(self[i])
    end

    return reversed
end

---@param ... any
function lib.array:unshift(...)
    local elements = { ... }
    local length = #self
    local eLength = #elements

    for i = length, 1, -1 do
        self[i + eLength] = self[i]
    end

    for i = 1, #elements do
        self[i] = elements[i]
    end

    return length + eLength
end

---@param tbl ArrayLike
---@return boolean
function lib.array.isArray(tbl)
    local tableType = table_type(tbl)

    if not tableType then return false end

    if tableType == 'array' or tableType == 'empty' or lib.array.instanceOf(tbl, lib.array) then
        return true
    end

    return false
end

return lib.array
