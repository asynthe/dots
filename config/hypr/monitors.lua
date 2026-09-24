hl.config({
	misc = {
		key_press_enables_dpms = true,
		mouse_move_enables_dpms = true,
	},
})

local disable_internal = false
local side = "left"
local laptop_bare = "AU Optronics 0xB0AE"
local laptop = "desc:" .. laptop_bare
local laptop_w = 1920

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
		scale = "1.2",
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
	-- {
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

local laptop_ws_count = 2
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
	for i = 1, 10 do
		ws_rules[i] = hl.workspace_rule({
			workspace = tostring(i),
			monitor = i <= laptop_ws_count and laptop or ext,
		})
	end
end

local function laptop_active()
	for _, mon in ipairs(hl.get_monitors()) do
		if mon.description:find(laptop_bare, 1, true) then
			return true
		end
	end
	return false
end

local function rehome_workspaces()
	local ext_desc = detect_external()
	if not ext_desc or not laptop_active() then
		return
	end
	local ext = "desc:" .. ext_desc
	for _, ws in ipairs(hl.get_workspaces()) do
		local id = ws.id
		if id >= 1 and id <= 10 then
			local want_laptop = id <= laptop_ws_count
			local on_laptop = ws.monitor.description:find(laptop_bare, 1, true) ~= nil
			if want_laptop ~= on_laptop then
				hl.dispatch(hl.dsp.workspace.move({
					workspace = id,
					monitor = want_laptop and laptop or ext,
				}))
			end
		end
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
-- Also on a plain `hyprctl reload`: the rules above only bind a workspace as it
-- is created, so anything already open stays where it is without this.
rehome_workspaces()
hl.on("monitor.added", function()
	hl.timer(function()
		apply_monitors()
		hl.exec_cmd("hyprctl dispatch 'hl.dsp.dpms(\"on\")'")
		rehome_workspaces()
	end, { timeout = 500, type = "oneshot" })
end)
hl.on("monitor.removed", function()
	apply_monitors()
end)

hl.bind("switch:on:Lid Switch", function()
	if detect_external() then
		apply_monitors(true)
	end
end, { locked = true })

hl.bind("switch:off:Lid Switch", function()
	hl.timer(function()
		hl.monitor({ output = laptop, disabled = false })
		apply_monitors(false)
		rehome_workspaces()
	end, { timeout = 500, type = "oneshot" })
end, { locked = true })

local function toggle_laptop_screen()
	if laptop_active() then
		hl.monitor({ output = laptop, disabled = true })
		hl.timer(function()
			apply_monitors(true)
		end, { timeout = 500, type = "oneshot" })
	else
		hl.monitor({ output = laptop, disabled = false })
		apply_monitors(false)
		rehome_workspaces()
	end
end

return { toggle_laptop_screen = toggle_laptop_screen }
