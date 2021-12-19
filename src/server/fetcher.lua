-- A library to assist with getting utilities from this reposistory.

local HttpService = game:GetService("HttpService")
local git_repo = "https://raw.githubusercontent.com/techs-sus/void-utils/main/src/"
local server = git_repo .. "server/"
local client = git_repo .. "client/"

-- Usage:
--[[
fetch("server", "binder.lua") -- which would require the 'binder' module from this repository
]]
local function fetch(type: string, module: string)
	local thing = server
	if type == "client" then
		thing = client
	end
	local code = HttpService:GetAsync(thing .. module)
	return assert(loadstring(code))()
end

return fetch