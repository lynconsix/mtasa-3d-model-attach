-- https://www.lua.org/pil/2.5.html
function CountModelOccurrences(cache)
	local CountList = {}

	for Index, ModelId in ipairs(cache) do
		CountList[ModelId] = (CountList[ModelId] or 0) + 1
	end

	return CountList
end

-- https://www.lua.org/pil/2.5.html
function FindEmptyEntry(stack)
	for Index, Value in ipairs(stack) do
		if not Value then
			return Index
		end
	end

	return #stack + 1
end

-- https://wiki.multitheftauto.com/wiki/Table.size
function Length(stack)
	local Count = 0

	for Void in pairs(stack) do
		Count = Count + 1
	end

	return Count
end