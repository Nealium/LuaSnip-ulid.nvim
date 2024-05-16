local M = {}

--- Plugin health check
M.check = function()
    vim.health.report_start("luasnip-ulid report")
    if vim.fn.executable("date") then
        vim.health.report_ok("date command is executable")
    else
        vim.health.report_error("date command is missing")
    end
end

return M
