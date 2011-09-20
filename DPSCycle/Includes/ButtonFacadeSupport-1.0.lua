-----------------------------------------------------------
-- ButtonFacadeSupport-1.0.lua
-----------------------------------------------------------
-- This library provides an easy way for your addons to get supported by ButtonFacade,
-- so much easier than the way otherwise. It's really funny that the author of LibButtonFacade
-- did not write this file, but oh well...
--
-- Abin (2010-1-31)

-----------------------------------------------------------
-- API Documentation:
-----------------------------------------------------------

-- module = CreateButtonFacadeSupport("addon", db) -- Return a Buttonfacade supporting module, "addon"(string) usually being your addon name, "db"(table or string) is where you store your addon's persistant data
-- module:AddGroup("title", "prefix", count) -- Add a group of buttons with common naming sequence
-- module:AddGroup("title", button1, button2, ...) -- Add a group of buttons with no common naming sequence
-- module:GetGroup("title") -- Returns a group created by a previous call of module:AddGroup(...)

-----------------------------------------------------------
-- Simple Usage:
-----------------------------------------------------------

-- Assume you are using this library in an addon named "MyAddon".
-- First make sure the following 2 lines exists in "MyAddon.toc":

-- ## OptionalDeps: ButtonFacade
-- ## SavedVariables: MyAddonDB

-- Then in your lua file write the following code to make Buttonfacade recognize
-- your addon buttons and skin MyAddonButton1 - MyAddonButton10:

-- local module = CreateButtonFacadeSupport("MyAddon", "MyAddonDB")
-- if module then
--	module:AddGroup("MyAddonButtons", "MyAddonButton", 10)
-- end

-----------------------------------------------------------

local type = type
local select = select
local getglobal = getglobal
local tinsert = tinsert
local pairs = pairs
local ipairs = ipairs
local IsAddOnLoaded = IsAddOnLoaded
local error = error
local format = format
local unpack = unpack
local wipe = wipe

local MAJOR_VERSION = 1
local MINOR_VERSION = 3

-- To prevent older libraries from over-riding newer ones...
if type(CreateButtonFacadeSupport_IsNewerVersion) == "function" and not CreateButtonFacadeSupport_IsNewerVersion(MAJOR_VERSION, MINOR_VERSION) then return end

-- Ensure existance of the subtable
local function PrepareDB(db, key)
	if not key then
		key = "ButtonFacade Groups"
	end

	if type(db[key]) ~= "table" then
		db[key] = {}
	end
	return db[key]
end

-- Required by ButtonFacade
local function Module_SkinCallback(self, skin, gloss, backdrop, group, button, colors)
	if group then
		local db = PrepareDB(self.db, group)
		db.skin, db.gloss, db.backdrop, db.colors = skin, gloss, backdrop, colors
	end

	if type(self.OnSkinChanged) == "function" then
		self:OnSkinChanged(skin, gloss, backdrop, group, button, colors)
	end
end

-- Add a group of buttons after module:OnEnable is called
local function Module_ApplyGroup(self, title, ...)
	local group = self.groups[title]
	if not group then
		group = self.libButtonFacade:Group(self.addon, title)
		if not group then
			return
		end
		self.groups[title] = group
	end

	local prefix, count = ...
	local sequencial = type(prefix) == "string" and type(count) == "number"
	if not sequencial then
		count = select("#", ...)
	end

	local i
	for i = 1, count do
		local button = sequencial and getglobal(prefix..i) or select(i, ...)
		if button then
			group:AddButton(button)
		end
	end

	local db = PrepareDB(self.db, title)
	group:Skin(db.skin, db.gloss, db.backdrop, db.colors)
	return group
end

local function Module_AddGroup(self, title, ...)
	if type(title) ~= "string" then
		return
	end

	if self.moduleOnEnableCalled then
		Module_ApplyGroup(self, title, ...)
	else
		local data = self.data[title]
		if not data then
			data = {}
			self.data[title] = data
		end
		tinsert(data, {...})
	end
end

local function Module_GetGroup(self, title)
	if type(title) == "string" then
		return self.groups[title]
	end
end

local function Module_OnEnable(self)
	self.moduleOnEnableCalled = 1
	if self.dbName then
		local db = getglobal(self.dbName)
		if type(db) == "table" then
			self.db = PrepareDB(db)
		end
		self.dbName = nil
	end

	local title, list
	for title, list in pairs(self.data) do
		local data
		for _, data in ipairs(list) do
			Module_ApplyGroup(self, title, unpack(data))
		end
	end

	wipe(self.data)
end

function CreateButtonFacadeSupport(addon, db)
	if not IsAddOnLoaded("ButtonFacade") or not LibStub then
		return
	end

	local ACE3 = LibStub("AceAddon-3.0")
	if not ACE3 then
		return
	end

	local BF = ACE3:GetAddon("ButtonFacade")
	local LBF = LibStub("LibButtonFacade", true)
	if not BF or not LBF then
		return
	end

	if type(addon) ~= "string" then
		error(format("bad argument #1 to 'CreateButtonFacadeSupport' (string expected, got %s)", type(addon)))
		return
	end

	local dbType = type(db)
	if dbType ~= "string" and dbType ~= "table" then
		error(format("bad argument #2 to 'CreateButtonFacadeSupport' (table or string expected, got %s)", dbType))
		return
	end

	local module = BF:NewModule(addon)
	if not module then
		return
	end

	module.libButtonFacade = LBF
	module.addon = addon
	module.data = {}
	module.groups = {}

	if dbType == "table" then
		module.db = PrepareDB(db)
	else
		module.db = {}
		module.dbName = db
	end

	LBF:RegisterSkinCallback(addon, Module_SkinCallback, module)

	module.AddGroup = Module_AddGroup
	module.GetGroup = Module_GetGroup
	module.OnEnable = Module_OnEnable
	return module
end

-- Provides version check
function CreateButtonFacadeSupport_IsNewerVersion(major, minor)
	if type(major) ~= "number" or type(minor) ~= "number" then
		return false
	end

	if major > MAJOR_VERSION then
		return true
	elseif major < MAJOR_VERSION then
		return false
	else -- major equal, check minor
		return minor > MINOR_VERSION
	end
end