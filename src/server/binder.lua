local RunService = game:GetService("RunService")
local api = {}
api.__index = api

type AmongUsInputReader = {
	bindKey: (player: Player, keycode: Enum.KeyCode) -> {onKeyDown: RBXScriptSignal, onKeyUp: RBXScriptSignal},
	unbindKey: (player: Player, keycode: Enum.KeyCode) -> nil
}

function api.new(): AmongUsInputReader
	return setmetatable({
		_onKeyDown = Instance.new("BindableEvent"),
		_onKeyUp = Instance.new("BindableEvent"),
		_inputs = {}
	}, api)
end

function api:bindKey(player: Player, keycode: Enum.KeyCode)
	for _, v in pairs(player.Character.Head:GetChildren()) do
		if v:IsA("ProximityPrompt") and (v.Name == "_onKeyPressed" .. tostring(keycode)) then
			v:Destroy()
		end
	end
	self._inputs[player] = {}
	local isKeyDown = false
	local timeKeyDown = 0
	local input = Instance.new("ProximityPrompt")
	local bindable = Instance.new("BindableEvent")
	local bindable2 = Instance.new("BindableEvent")
	input.Name = "_onKeyPressed" .. tostring(keycode)
	input.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
	input.KeyboardKeyCode = keycode
	input.Style = Enum.ProximityPromptStyle.Custom
	input.HoldDuration = math.huge
	input.PromptButtonHoldBegan:Connect(function(playerWhoTriggered: Player)
		if playerWhoTriggered == player then
			bindable:Fire(player, keycode)
			self._onKeyDown:Fire(player, keycode)
			isKeyDown = true
		end
	end)
	input.PromptButtonHoldEnded:Connect(function(playerWhoTriggered: Player)
		if playerWhoTriggered == player then
			bindable2:Fire(player, keycode, timeKeyDown)
			self._onKeyUp:Fire(player, keycode, timeKeyDown)
			isKeyDown = false
			timeKeyDown = 0
		end
	end)
	local conn
	conn = RunService.Heartbeat:Connect(function(dt: number)
		if isKeyDown then
			timeKeyDown += dt
		end
		self._inputs[player][keycode].timeKeyDown = timeKeyDown
		self._inputs[player][keycode].isKeyDown = isKeyDown
		if not input:IsDescendantOf(workspace) then
			pcall(function()
				input.Parent = player.Character
			end)
			isKeyDown = false
			timeKeyDown = 0
			return
		end
	end)
	input.Parent = player.Character.Head
	self._inputs[player][keycode] = {
		keyEvents = {onKeyDown = bindable.Event, onKeyUp = bindable2.Event},
		onDestroy = function()
			if conn then
				conn:Disconnect()
				conn = nil
			end
			input:Destroy()
			bindable:Destroy()
			bindable2:Destroy()
			self._inputs[player][keycode].destroyed = true
		end,
		timeKeyDown = timeKeyDown,
		isKeyDown = isKeyDown,
		destroyed = false,
		_proximityPrompt = input
	}
	return self._inputs[player][keycode]
end

function api:unbindKey(player: Player, keycode: Enum.KeyCode)
	if self._inputs[player] and self._inputs[player][keycode] then
		self._inputs[player][keycode].onDestroy()
	end
end

return api
