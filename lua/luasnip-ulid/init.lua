---
--  Add ULID snippet to LuaSnip
--  (Universally Unique Lexicographically Sortable Identifiers)
--
-- @see Javascript: [ulid/javascript](https://github.com/ulid/javascript)
-- @see Python: [ahawker/ulid](https://github.com/ahawker/ulid)
--
-- @author Neal Joslin
-- @date 2024-04-29
local ulid = require("luasnip-ulid.ulid")

local M = {}

--- Plugin Setup
function M.load_snippets()
    local luasnip = require("luasnip")
    for ft, snips in pairs(ulid) do
        luasnip.add_snippets(ft, snips)
    end
end

return M
