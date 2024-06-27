-- Check telescope is installed
local ok, _ = pcall(require, 'telescope')
if not ok then
    vim.notify('Install nvim-telescope/telescope.nvim to use 4542elgh/telescope-arsenal.nvim.', vim.log.levels.ERROR)
end

local arsenals = {}
local handle = vim.loop.fs_scandir(vim.fn.stdpath("config") .. vim.g.separator .. "lua" .. vim.g.separator .. "arsenal")

while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then break end
    if type == 'file' then
        table.insert(arsenals, name)
    end
end

-- Telescope utils
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values

local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

-- Make format better
local function make_arsenal()
    local languagesPicker = {}
    for _, val in ipairs(arsenals) do
        table.insert(languagesPicker, {
            toolName = val
            -- lang = val.name,
            -- cmd = val.cmd,
        })
    end
    return languagesPicker
end

-- This is what will be showing in Telescope
local function make_entry()
    -- Spacing
    local displayer = entry_display.create {
        separator = "",
        items = {
            { width = 15 },
            { remaining = true }
        }
    }

    -- What content is displaying
    local make_display = function(entry)
        return displayer {
            entry.toolName,
        }
    end

    -- Internal sorting
    return function(entry)
        return {
            value = entry,
            ordinal = entry.toolName,
            display = make_display,
            -- lang = entry.lang,
            -- cmd = entry.cmd,
        }
    end
end

-- Finder will fill picker with items
local make_finder = function()
    return finders.new_table {
        results = make_arsenal(),
        entry_maker = make_entry(),
    }
end

-- Displaying module, putting everything together
local function make_picker()
    pickers.new({}, {
        prompt_title = "Arsenal tools",
        finder = make_finder(),
        sorter = conf.generic_sorter({}),

        -- What to do with selected item
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                vim.cmd(action_state.get_selected_entry().toolName)
            end)
            return true
        end,
    }):find()
end

return require("telescope").register_extension {
    -- setup = function(user_opts, _)
    --     -- if next(user_opts) ~= nil then
    --         -- compilers = vim.tbl_extend('force', compilers, user_opts.custom_compilers)
    --         -- opts = vim.tbl_extend('force', default_opts, user_opts)
    --     -- end
    -- end,
    exports = {
        arsenal = make_picker
    }
}
