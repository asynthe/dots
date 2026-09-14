hl.config({
	misc = {
		key_press_enables_dpms = true,
		mouse_move_enables_dpms = true,
	},
})

-- Sticky: set true once the panel is explicitly turned off, so a hotplug
-- (a TV dropping its link on standby) can't resurrect it via apply_monitors().
local disable_internal = false
-- "left": laptop left | "right": laptop right
local side = "left"
local laptop_bare = "AU Optronics 0xB0AE"
local laptop = "desc:" .. laptop_bare
local laptop_w = 1920

-- @@@ 5655SMART TV 0x00011011
-- HP Inc. HP P24v G4 1CR10315PN
-- Hisense Electric Co. Ltd. HISENSE 0x00000001
-- LG Electronics LG TV 0x01010101
-- Nreal MGMG2710C
-- Panasonic Industry Company Panasonic-TV 0x01010101
-- SANTAK CORP. S2-TEK TV SN-000000001
-- Samsung Electric Company S34CG50 HNBYC00076
-- Samsung Electric Company SAMSUNG 0x01000E00
-- Sony SONY TV 0x01010101

local known_externals = {
	{
		match = "0x00011011",
		output = "desc: @@@ 5655SMART TV 0x00011011",
		mode = "1920x1080@60",
		scale = "1.3",
		width = 1920,
	},
	{
		match = "1CR10315PN",
		output = "desc: HP Inc. HP P24v G4 1CR10315PN",
		mode = "1920x1080@60",
		scale = "1",
		width = 1920,
	},
	{
		match = "HISENSE",
		output = "desc: Hisense Electric Co. Ltd. HISENSE 0x00000001",
		mode = "1920x1080@60",
		scale = "1.25",
		width = 1920,
	},
	{
		match = "LG TV",
		output = "desc: LG Electronics LG TV 0x01010101",
		mode = "1920x1080@60",
		scale = "1.3",
		width = 1920,
	},
	{
		match = "MGMG2710C",
		output = "desc: Nreal MGMG2710C",
		mode = "1920x1080@60",
		scale = "1",
		width = 1920,
	},
	{
		match = "Panasonic-TV",
		output = "desc: Panasonic Industry Company Panasonic-TV 0x01010101",
		mode = "1920x1080@60",
		scale = "1",
		width = 1920,
	},
	{
		match = "S2-TEK TV",
		output = "desc: SANTAK CORP. S2-TEK TV SN-000000001",
		mode = "1920x1080@60",
		scale = "1",
		width = 1920,
	},
	{
		match = "S34CG50",
		output = "desc: Samsung Electric Company S34CG50 HNBYC00076",
		mode = "3440x1440@100",
		scale = "1",
		width = 3440,
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
		match = "SONY TV",
		output = "desc: Sony SONY TV 0x01010101",
		mode = "1920x1080@60",
		scale = "1",
		width = 1920,
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

-- Workspace 1 goes to whichever screen is on the left; the laptop keeps one
-- workspace, the external takes the rest. Never torn down on a disconnect: a
-- monitor that drops its DP link in standby needs the rules already in place
-- when it reconnects, since Hyprland relocates workspaces before Lua runs.
local ws_rules = {}
local ws_pinned = nil

local function pin_workspaces(ext_desc)
	if not ext_desc or ws_pinned == ext_desc then
		return
	end
	for _, rule in ipairs(ws_rules) do
		rule:set_enabled(false)
	end
	ws_rules = {}
	ws_pinned = ext_desc

	local ext = "desc:" .. ext_desc
	local laptop_ws = side == "left" and 1 or 2
	for i = 1, 10 do
		ws_rules[i] = hl.workspace_rule({
			workspace = tostring(i),
			monitor = i == laptop_ws and laptop or ext,
		})
	end
end

local function apply_monitors(force_disable_internal)
	if force_disable_internal ~= nil then
		disable_internal = force_disable_internal
	end
	local disable = disable_internal

	local ext_desc = detect_external()
	pin_workspaces(ext_desc)
	if not ext_desc then
		disable_internal = false
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
	local lpos = side == "left" and "0x0" or (ext_w .. "x0")
	local epos = disable and "0x0" or (side == "left" and (laptop_w .. "x0") or "0x0")

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
-- Delay: a monitor restoring its link while the panel is still dpms-off will
-- otherwise claim the internal's crtc slot before we reconfigure.
hl.on("monitor.added", function()
	hl.timer(function()
		apply_monitors()
		hl.exec_cmd("hyprctl dispatch 'hl.dsp.dpms(\"on\")'")
	end, { timeout = 500, type = "oneshot" })
end)
hl.on("monitor.removed", function()
	apply_monitors()
end)

-- Lid switch
hl.bind("switch:on:Lid Switch", function()
	if detect_external() then
		apply_monitors(true)
	end
end, { locked = true })

hl.bind("switch:off:Lid Switch", function()
	hl.timer(function()
		hl.monitor({ output = laptop, disabled = false })
		apply_monitors(false)
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
		hl.timer(function()
			apply_monitors(true)
		end, { timeout = 500, type = "oneshot" })
	else
		hl.monitor({ output = laptop, disabled = false })
		apply_monitors(false)
	end
end

return { toggle_laptop_screen = toggle_laptop_screen }
