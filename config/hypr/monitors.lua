hl.config({
    misc = {
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,
    },
})

local disable_internal = false
-- "left": laptop left | "right": laptop right
local side             = "left"
local laptop_bare      = "AU Optronics 0xB0AE"
local laptop      = "desc:" .. laptop_bare
local laptop_w    = 1920

-- @@@ 5655SMART TV 0x00011011
-- HP Inc. HP P24v G4 1CR10315PN
-- Hisense Electric Co. Ltd. HISENSE 0x00000001
-- LG Electronics LG TV 0x01010101
-- Nreal MGMG2710C
-- Panasonic Industry Company Panasonic-TV 0x01010101
-- Samsung Electric Company S34CG50 HNBYC00076
-- Samsung Electric Company SAMSUNG 0x01000E00
-- Sony SONY TV 0x01010101
local known_externals = {
    {
        match  = "0x00011011",
        output = "desc: @@@ 5655SMART TV 0x00011011",
        mode   = "1920x1080@60",
        scale  = "1.3",
        width  = 1920,
    },
    {
        match  = "1CR10315PN",
        output = "desc: HP Inc. HP P24v G4 1CR10315PN",
        mode   = "1920x1080@60",
        scale  = "1",
        width  = 1920,
    },
    {
        match  = "0x00000001",
        output = "desc: Hisense Electric Co. Ltd. HISENSE 0x00000001",
        mode   = "1920x1080@60",
        scale  = "1.25",
        width  = 1920,
    },
    {
        match  = "0x01010101",
        output = "desc: LG Electronics LG TV 0x01010101",
        mode   = "1920x1080@60",
        scale  = "1.3",
        width  = 1920,
    },
    {
        match  = "MGMG2710C",
        output = "desc: Nreal MGMG2710C",
        mode   = "1920x1080@60",
        scale  = "1",
        width  = 1920,
    },
    {
        match  = "0x01010101",
        output = "desc: Panasonic Industry Company Panasonic-TV 0x01010101",
        mode   = "1920x1080@60",
        scale  = "1",
        width  = 1920,
    },
    {
        match  = "S34CG50",
        output = "desc: Samsung Electric Company S34CG50 HNBYC00076",
        mode   = "3440x1440@100",
        scale  = "1",
        width  = 3440,
    },
    -- Samsung Electric Company SAMSUNG 0x01000E00
    -- {
    --     match  = "0x01000E00",
    --     output = "desc: Samsung Electric Company SAMSUNG 0x01000E00",
    --     mode   = "1920x1080@60",
    --     scale  = "1",
    --     width  = 1920,
    -- },
    {
        match  = "0x01010101",
        output = "desc: Sony SONY TV 0x01010101",
        mode   = "1920x1080@60",
        scale  = "1",
        width  = 1920,
    },
}

local function detect_external()
    for _, mon in ipairs(hl.get_monitors()) do
        if not mon.description:find(laptop_bare, 1, true) then
            return mon.description
        end
    end
    return nil
end

local function apply_monitors(force_disable_internal)
    local disable = force_disable_internal or disable_internal

    local ext_desc = detect_external()
    if not ext_desc then
        hl.monitor({ output = laptop, mode = "1920x1200@60", position = "0x0", scale = "1" })
        return
    end

    local ext = nil
    for _, known in ipairs(known_externals) do
        if ext_desc:find(known.match, 1, true) then
            ext = known
            break
        end
    end

    local ext_w = ext and ext.width or laptop_w
    local lpos  = side == "left" and "0x0"           or (ext_w    .. "x0")
    local epos  = disable and "0x0" or (side == "left" and (laptop_w .. "x0") or "0x0")

    if not disable then
        hl.monitor({ output = laptop, mode = "1920x1200@60", position = lpos, scale = "1" })
    else
        hl.monitor({ output = laptop, disabled = true })
    end
    if ext then
        hl.monitor({ output = ext.output, mode = ext.mode, position = epos, scale = ext.scale })
    else
        hl.monitor({ output = "desc:" .. ext_desc, position = epos })
    end
end

apply_monitors()
hl.on("monitor.added", function()
    apply_monitors()
    hl.exec_cmd("hyprctl dispatch 'hl.dsp.dpms(\"on\")'")
end)
hl.on("monitor.removed", function() apply_monitors() end)

-- Lid switch
hl.bind("switch:on:Lid Switch", function()
    if detect_external() then
        apply_monitors(true)
    end
end, { locked = true })

hl.bind("switch:off:Lid Switch", function()
    hl.timer(function()
        hl.monitor({ output = laptop, disabled = false })
        apply_monitors()
    end, { timeout = 500, type = "oneshot" })
end, { locked = true })

-- Toggle laptop screen; checks live state so lid switch can't desync it
local function toggle_laptop_screen()
    local active = false
    for _, mon in ipairs(hl.get_monitors()) do
        if mon.description:find(laptop_bare, 1, true) then
            active = true
            break
        end
    end
    if active then
        hl.monitor({ output = laptop, disabled = true })
        hl.timer(function() apply_monitors(true) end, { timeout = 500, type = "oneshot" })
    else
        hl.monitor({ output = laptop, disabled = false })
        apply_monitors()
    end
end

return { toggle_laptop_screen = toggle_laptop_screen }
