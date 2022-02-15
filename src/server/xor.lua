local function encode(input)
	local encoded = {}
	for i = 1, #input do
		encoded[i] = string.byte(input, i, i)
	end
	return encoded
end

local function xorDecrypt(input: string, password2: string)
	local password = encode(password2)
	local decrypted = ""
	for _, byte in ipairs(string.split(input, ";")) do
		local index = _ - 1
		local unlocked = bit32.bxor(tonumber(byte), password[index % #password + 1])
		decrypted ..= string.char(unlocked)
	end
	return decrypted
end

local function xorEncrypt(input2, password)
	local input = encode(input2)
	local encryptedArray = table.create(#input)
	for _, byte in ipairs(input) do
		local index = _ - 1
		encryptedArray[_] = bit32.bxor(byte, password[index % #password + 1])
	end
	return table.concat(encryptedArray, ";")
end

return {
	encrypt = xorEncrypt,
	decrypt = xorDecrypt
}