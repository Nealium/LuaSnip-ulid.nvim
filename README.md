# LuaSnip-ulid.nvim

Adds a ULID snippet to [LuaSnip](https://github.com/L3MON4D3/LuaSnip). Example: `01HWP73EY83X6FAHG3DQKCHJMA`    
> Uses: [ahawker/ulid](https://github.com/ahawker/ulid)'s algorithm for generation *([specifically](https://github.com/ahawker/ulid/blob/06289583e9de4286b4d80b4ad000d137816502ca/ulid/base32.py#L102)*)    
> See: [ulid/javascript](https://github.com/ulid/javascript) for information about ULID    
    
#### **Why?**
I quite enjoy the `uuid` snippet and wanted a `ulid` one. I find it quite
convenient while making dummy data in databases to hardcode those fields,
especially after a few database wipes + repopulations. Having it a snippet means
it's always at your fingertips!

## Requirements
**Bash**. Must have access to the `date` command.
> I would be open to alternatives. My original starting point for this plugin
> was [Tieske/ulid.lua](https://github.com/Tieske/ulid.lua), and he used
> `ngx.now()` and `LuaSocket`. Both of which are extra dependencies, and thus I
> stuck to using Bash's Date command. **Note:** the reason I doesn't using
> something like `os.time()` is that command doesn't provide milliseconds, which
> is required to get a "proper" ulid

## Install
* https://github.com/folke/lazy.nvim
```lua
{
    "Nealium/LuaSnip-ulid.nvim",
    dependencies = {
        { "L3MON4D3/LuaSnip" },
    },
    config = function()
        require("luasnip-ulid").load_snippets()
    end,
},
```


## Manual
If you instead don't want to add **another** plugin, I understand, this might be a
better route especially if you plan on adding your own custom snippets at some
point. I designed this plugin with this in mind.

> **Note:** This would require any additional snippets from you to be
> "Lua Snippets."See: [Lua Snippets for beginners](https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#resources-for-new-users),
> [LuaSnip.DOC.md](https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md), or 
> if you're like me and just want to see code, look at [LuaSnip-snippets.nvim](https://github.com/molleweide/LuaSnip-snippets.nvim)-
> their [lua/luasnip_snippets/snippets/all.lua](https://github.com/molleweide/LuaSnip-snippets.nvim/blob/d7e40e4cce622eab2316607dbcd8d6039bcb9fe0/lua/luasnip_snippets/snippets/all.lua#L41)
> is a good place to start.

### Copy File
1. Create a dir `~/.config/nvim/lua/snippets`
1. Create a file `~/.config/nvim/lua/snippets/ulid.lua`
2. Copy contents of `lua/luasnip-ulid/ulid.lua` and place into the newly created file

### Importing

#### Easy way
Install [LuaSnip-snippets.nvim](https://github.com/molleweide/LuaSnip-snippets.nvim)
and configure is as the README says. This will auto check that `lua/snippets`
directory and add all snippets in the files.

#### Hard(er) way
As we don't want extra plugins, adding this block of code will essentially do
the same thing, but without all the snippets provided with [LuaSnip-snippets.nvim](https://github.com/molleweide/LuaSnip-snippets.nvim):
```lua
{
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp"
    config = function ()

        -- This Block
        local luasnip = require("luasnip")
        for _, snip_fpath in
            ipairs(
                vim.api.nvim_get_runtime_file("lua/snippets/*.lua", true)
            )
        do
            local snip_mname = snip_fpath:match("^.+/(.+)$"):sub(1, -5)

            local sm = require("snippets." .. snip_mname)

            for ft, snips in pairs(sm) do
                luasnip.add_snippets(ft, snips)
            end
        end
        -- This Block END

    end
}
```
> all props to [LuaSnip-snippets.nvim](https://github.com/molleweide/LuaSnip-snippets.nvim)
> for the block above. I just condensed it and changed it to use `add_snippets`

## Sources
<details>

<summary>ahawker/ulid</summary>

* **Link:** [ahawker/ulid](https://github.com/ahawker/ulid)
* **Copyright:** Copyright 2017 Andrew R. Hawker
* **License:** [Apache 2.0]([https://opensource.org/license/apache-2-0](https://opensource.org/license/apache-2-0))
* **Author:** Andrew Hawker
* **Use:**
   * ULID generation algorithm (bitwise arthritic **should** be 1-to-1)
   * General values -> bytes idea
</details>

<details>

<summary>Tieske/ulid.lua</summary>

* **Link:** [Tieske/ulid.lua](https://github.com/Tieske/ulid.lua)
* **Copyright:** Copyright 2016-2017 Thijs Schreijer
* **License:** [mit](https://opensource.org/licenses/MIT)
* **Author:** Thijs Schreijer
* **Use:**
    * Starting point for `ulid.lua` file
    * Constants
    * Random loop, though contents changed
        * the loop gave me an epiphany to try to randomly generate bytes,
          instead of a large number
</details>
