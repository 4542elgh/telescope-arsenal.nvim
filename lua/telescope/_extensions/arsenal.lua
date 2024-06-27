-- Check telescope is installed
local ok, _ = pcall(require, 'telescope')
if not ok then
    vim.notify('Install nvim-telescope/telescope.nvim to use 4542elgh/telescope-arsenal.nvim.', vim.log.levels.ERROR)
end

local arsenals = {}
local default_opts = {
    path = vim.fn.stdpath("config") .. vim.g.separator .. "arsenal"
}
local handle = vim.loop.fs_scandir(default_opts.path)

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
            { width = 30 },
            { remaining = true }
        }
    }

    -- What content is displaying
    local make_display = function(entry)
        return displayer {
            entry.toolName
        }
    end

    -- Entry will be from make_arsenal()
    -- Define what needs to be in make_display()
    return function(entry)
        return {
            value = entry,
            -- Internal sorting
            ordinal = entry.toolName,
            display = make_display,
            -- Used in make_display()
            toolName = entry.toolName
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
                vim.cmd("edit " .. default_opts.path .. vim.g.separator .. action_state.get_selected_entry().toolName)
            end)
            return true
        end,
    }):find()
end

return require("telescope").register_extension {
    setup = function(user_opts, _)
        if next(user_opts) ~= nil then
            vim.tbl_extend('force', default_opts, user_opts)
        end
    end,
    exports = {
        arsenal = make_picker
    }
}
