function Random(set)
	-- via http://stackoverflow.com/questions/22321277/randomly-select-a-key-from-a-table-in-lua
	local choice = nil
	local n = 0
	for el, _ in pairs(set) do
		n = n + 1
		if math.random() < (1/n) then
			choice = el
		end
	end
	return choice
end


