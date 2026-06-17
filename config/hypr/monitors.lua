-- ───────────────────────── Monitors ─────────────────────────
local laptop   = "desc:AU Optronics 0xB0AE"
local external = "desc:Samsung Electric Company S34CG50 HNBYC00076"
local side     = "left" -- "left", "right"
local disable_laptop_screen = false

local function positions(side)
    if side == "left" then
        return { laptop = "0x0", external = "1920x0" }
    else
        return { laptop = "1920x0", external = "0x0" }
    end
end

local pos           = positions(side)
local cfg_laptop    = { output = laptop,   mode = "1920x1200@60",  position = pos.laptop,   scale = "1" }
local cfg_external  = { output = external, mode = "3440x1440@100", position = pos.external, scale = "1" }

local function get_external()
    local handle = io.popen(
        'hyprctl -j monitors | jq -r --arg laptop "' .. laptop .. '" ' ..
        '"[.[] | select(.description != null and ($laptop | inside(.description) | not))] | first | .description // empty"'
    )
    local result = handle:read("*a"):gsub("%s+", "")
    handle:close()
    if result == "" then return nil end
    return result
end

hl.monitor(cfg_laptop)
hl.monitor(cfg_external)

-- Close laptop lid
hl.bind("switch:on:Lid Switch", function()
    hl.monitor({ output = laptop, disabled = true })
    -- TODO Set up a lock screen
    --if not get_external() then
        --hl.dispatch(hl.dsp.exec_cmd("loginctl lock-session"))
    --end
end)

-- Open laptop lid
hl.bind("switch:off:Lid Switch", function()
    hl.monitor({ output = laptop, disabled = false })
    hl.monitor(cfg_laptop)
end)

-- Disable laptop monitor variable
if disable_laptop_screen then
    hl.monitor({ output = laptop, disabled = true })
end
