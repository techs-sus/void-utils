-- A library for fixing ImageLabels and Parts having excessive limits.

local oldInstance = Instance
Instance = {}
function Instance.new(className: string, parent: Instance?)
	if className == "Part" then
		local part = oldInstance.new("SpawnLocation")
		part.Enabled = false
		part.Locked = true
		part.CanQuery = false
		part.Parent = parent
		return part
	elseif className == "ImageLabel" then
		local bypass = oldInstance.new("ImageButton")
		bypass.AutoButtonColor = false
		bypass.Active = false
		bypass.Parent = parent
		return bypass
	else
		return oldInstance.new(className, parent)
	end
end

return oldInstance