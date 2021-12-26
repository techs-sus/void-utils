-- Credits to @boatbomber & the people who made hashlib
-- I just minified it and fixed it for void
local HttpService = game:GetService("HttpService")
local hashlib = "https://paste.ee/r/kNiOL"
local alive, code, f

repeat
	alive, code = pcall(HttpService.GetAsync, HttpService, hashlib)
	if code then
		f = loadstring(code)
	end
	task.wait()
until (alive and code and f) ~= nil

return f()