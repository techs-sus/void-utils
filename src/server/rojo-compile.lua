-- This file enables Rojo compilation.
-- The compiler is pretty fast, but I would recommend keeping the size of the project <1mb.

local HttpService = game:GetService("HttpService")
---@module libs/promise
local Promise
do
	local code = string.gsub(
		HttpService:GetAsync("https://raw.githubusercontent.com/evaera/roblox-lua-promise/master/lib/init.lua"),
		"coroutine.close",
		"task.cancel"
	)
	Promise = loadstring(code)()
end
-- https://api.github.com/repos/roblox/roact/contents/src
local function jsonGet(url)
	return HttpService:JSONDecode(HttpService:GetAsync(url))
end

type File = {
	name: string,
	path: string,
	type: string,
	url: string,
	download_url: string,
	src: string,
}

function recurse(file: File, files)
	return Promise.new(function(resolve)
		if file.type == "dir" then
			local temp = {}
			for _, item in jsonGet(file.url) do
				table.insert(temp, recurse(item, files))
			end
			Promise.all(temp):await()
			return resolve()
		end
		file.src = HttpService:GetAsync(file.download_url)
		files[file.path] = file
		resolve(file.size)
	end)
end

local function createAllInstances(files)
	for _, file: File in files do
		if file.path ~= "src/init.lua" then
			local path = string.sub(file.path, 5)
			local split = string.split(path, "/")
			local value = Instance.new("StringValue")
			value.Value = file.src
			value:SetAttribute("path", path)
			if #split > 1 then
				local folder = script:FindFirstChild(split[1])
				if not folder then
					folder = Instance.new("Folder")
					folder.Name = split[1]
					folder.Parent = script
				end
				value.Name = string.sub(split[#split], 1, #split[#split] - 4)
				value.Parent = folder
			else
				value.Name = string.sub(path, 1, #path - 4)
				value.Parent = script
			end
		end
	end
end

local dependencyCache = {}
function compileFile(source, ins)
	local func = loadstring(source)
	return setfenv(
		func,
		setmetatable({
			script = ins or script,
			require = function(instance)
				local name = instance:GetFullName()
				if not dependencyCache[name] then
					dependencyCache[name] = { result = compileFile(instance.Value, instance)() }
				end
				return dependencyCache[name].result
			end,
		}, { __index = getfenv(0) })
	)
end

local function compileProject(repo: string): (any, number)
	local files = {}
	local promises = {}
	local initial = jsonGet(string.format("https://api.github.com/repos/%s/contents/src", repo))
	for _, file: File in initial do
		table.insert(promises, recurse(file, files))
	end
	local bytes = 0
	Promise.all(promises)
		:andThen(function(array)
			for _, v in pairs(array) do
				bytes += v
			end
			createAllInstances(files)
		end)
		:catch(function()
			error("failed hydrating files", 0)
			coroutine.yield()
		end)
		:await()
	return compileFile(files["src/init.lua"].src)(), math.floor(bytes / 1024)
end

return compileProject
