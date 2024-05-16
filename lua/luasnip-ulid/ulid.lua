---
--  Main functionality for generating ULIDs
--
-- @author Neal Joslin
-- @date 2024-04-29
--
-- @note
--  This heavily depends on the bash command `date +%s%N | cut -b1-13`, if not
--  avaliable I'm sure `get_time()` can be changed to call a different command.
--  Any potential change should have milliseconds. Example: `1714431071322` (13)
--
-- @note
--  This was made for Lua 5.1.5, hence the need for all the Bitwise operations
--  instead of using the built in function provided in newer versions
--
-- @sources
--  [ahawker/ulid](https://github.com/ahawker/ulid)
--      @copyright Copyright 2017 Andrew R. Hawker
--      @license [Apache 2.0](https://opensource.org/license/apache-2-0)
--      @author Andrew Hawker
--  @use
--      ULID generation algorithm
--
--  [Tieske/ulid.lua](https://github.com/Tieske/ulid.lua)
--      @copyright Copyright 2016-2017 Thijs Schreijer
--      @license [mit](https://opensource.org/licenses/MIT)
--      @author Thijs Schreijer
--  @use
--      Starting point of this file. General setup. ENCODING. random_bytes loop
--
-- @note
--  Thijs Schreijer has left a note saying Lua's time functions are randomizers
--  are very weak, "So make sure to set it up properly!" I definitely didn't do
--  any of that. I've edited the program os use bash to get the time and then
--  used that as a seed in the randomizer, I'm sure that **should** be enough.
local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node

-- Crockford's Base32 https://en.wikipedia.org/wiki/Base32
local ENCODING = {
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "J",
    "K",
    "M",
    "N",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "V",
    "W",
    "X",
    "Y",
    "Z",
}
local TIME_LEN = 6
local RANDOM_LEN = 10

---@alias decimal integer

---Bitwise AND
---@param a decimal
---@param b decimal
---@return decimal
local function bit_and(a, b)
    local p, c = 1, 0
    while a > 0 and b > 0 do
        local ra, rb = a % 2, b % 2
        if ra + rb > 1 then
            c = c + p
        end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    return c
end

---Bitwise OR
---@param a decimal
---@param b decimal
---@return decimal
local function bit_or(a, b)
    local p, c = 1, 0
    while a + b > 0 do
        local ra, rb = a % 2, b % 2
        if ra + rb > 0 then
            c = c + p
        end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    return c
end

---Bitwise Left Shift
---@param x decimal
---@param by integer
---@return decimal
local function bit_lshift(x, by)
    if x == 0 then
        return 0
    end
    return x * 2 ^ by
end

---Bitwise Right Shift
---@param x decimal
---@param by integer
---@return decimal
local function bit_rshift(x, by)
    if x == 0 then
        return 0
    end
    return math.floor(x / 2 ^ by)
end

---Get Unix time with milliseconds using Bash
---@return integer|nil
local function get_time()
    local success, response = pcall(function()
        return vim.fn.system("date +%s%N | cut -b1-13")
    end)
    if not success then
        vim.notify(response, vim.log.levels.ERROR)
        return nil
    end
    return response
end

---Turn Unix time into a table of bytes
---@note integer -> hex -> byte
---@note table should be 6 bytes long
---@param time integer
---@return table<decimal>
local function time_bytes(time)
    local decimals = {}
    for byte in string.format("%+012X", time):gmatch("%x%x") do
        table.insert(decimals, tonumber(byte, 16))
    end
    return decimals
end

---Generate random bytes
---@note table should be 10 bytes long
---@param time integer
---@return table<decimal>
local function random_bytes(time)
    local decimals = {}
    math.randomseed(time)
    for _ = 1, RANDOM_LEN do
        table.insert(decimals, math.floor(math.random(0, 255)))
    end
    return decimals
end

---Combine both time and random tables
---@param time table<decimal>
---@param random table<decimal>
---@return table<decimal>
local function combine_tables(time, random)
    for i = 1, #random do
        time[#time + 1] = random[i]
    end
    return time
end

---Create ULID
---@return string|nil
local function generate()
    local time = get_time()
    if time == nil then
        return nil
    end

    -- generate bytes and combine
    local value = combine_tables(time_bytes(time), random_bytes(time))
    if #value ~= TIME_LEN + RANDOM_LEN then
        return nil
    end

    -- Do Magic
    return (
        ENCODING[bit_rshift(bit_and(value[1], 224), 5) + 1]
        .. ENCODING[bit_and(value[1], 31) + 1]
        .. ENCODING[bit_rshift(bit_and(value[2], 248), 3) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[2], 7), 2),
            bit_rshift(bit_and(value[3], 192), 6)
        ) + 1]
        .. ENCODING[bit_rshift(bit_and(value[3], 62), 1) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[3], 1), 4),
            bit_rshift(bit_and(value[4], 240), 4)
        ) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[4], 15), 1),
            bit_rshift(bit_and(value[5], 128), 7)
        ) + 1]
        .. ENCODING[bit_rshift(bit_and(value[5], 124), 2) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[5], 3), 3),
            bit_rshift(bit_and(value[6], 224), 5)
        ) + 1]
        .. ENCODING[bit_and(value[6], 31) + 1]
        .. ENCODING[bit_rshift(bit_and(value[7], 248), 3) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[7], 7), 2),
            bit_rshift(bit_and(value[8], 192), 6)
        ) + 1]
        .. ENCODING[bit_rshift(bit_and(value[8], 62), 1) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[8], 1), 4),
            bit_rshift(bit_and(value[9], 240), 4)
        ) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[9], 15), 1),
            bit_rshift(bit_and(value[10], 128), 7)
        ) + 1]
        .. ENCODING[bit_rshift(bit_and(value[10], 124), 2) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[10], 3), 3),
            bit_rshift(bit_and(value[11], 224), 5)
        ) + 1]
        .. ENCODING[bit_and(value[11], 31) + 1]
        .. ENCODING[bit_rshift(bit_and(value[12], 248), 3) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[12], 7), 2),
            bit_rshift(bit_and(value[13], 192), 6)
        ) + 1]
        .. ENCODING[bit_rshift(bit_and(value[13], 62), 1) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[13], 1), 4),
            bit_rshift(bit_and(value[14], 240), 4)
        ) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[14], 15), 1),
            bit_rshift(bit_and(value[15], 128), 7)
        ) + 1]
        .. ENCODING[bit_rshift(bit_and(value[15], 124), 2) + 1]
        .. ENCODING[bit_or(
            bit_lshift(bit_and(value[15], 3), 3),
            bit_rshift(bit_and(value[16], 224), 5)
        ) + 1]
        .. ENCODING[bit_and(value[15], 31) + 1]
    )
end

return {
    all = {
        s({
            trig = "ulid",
            docstring = "${ULID}",
            desc = "Implementation of ULID",
        }, {
            f(generate),
        }),
    },
}
