local MODELS_ATTACHMENTS_CACHE = {}

-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
addEventHandler("onPlayerResourceStart", getRootElement(), 
	function(loadedResource)
		if loadedResource ~= resource then
			return
		end

		triggerClientEvent(source, "onClientCustomReceiveCache", getResourceRootElement(), MODELS_ATTACHMENTS_CACHE)
	end
)

-- https://www.lua.org/pil/2.5.html
function IsModel3DAttachedToBone(identifier)
	return MODELS_ATTACHMENTS_CACHE[identifier] and true or false
end

-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
function Attach3DModelToBone(pedElement, modelId, bone, position, rotation, scale)
	assert(isElement(pedElement), "Attach3DModelToBone: Invalid pedElement")
	assert(modelId and bone, "Attach3DModelToBone: Invalid arguments")

	local RegisterId = FindEmptyEntry(MODELS_ATTACHMENTS_CACHE)
	local Instance = {}

	Instance.Visible = true
	Instance.PedElement = pedElement

	Instance.ModelId = modelId
	Instance.Bone = bone

	Instance.Position = position or {0, 0, 0}
	Instance.Rotation = rotation or {0, 0, 0}

	Instance.Scale = scale or {1, 1, 1}

	MODELS_ATTACHMENTS_CACHE[RegisterId] = Instance
	triggerClientEvent(getRootElement(), "onClientAttach3DModel", getResourceRootElement(), pedElement, modelId, bone, position, rotation, scale)

	return RegisterId
end

-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
function Detach3DModelFromBone(identifier)
	assert(MODELS_ATTACHMENTS_CACHE[identifier], "Detach3DModelFromBone: Invalid identifier")

	local Instance = MODELS_ATTACHMENTS_CACHE[identifier]
	MODELS_ATTACHMENTS_CACHE[identifier] = nil

	return triggerClientEvent(getRootElement(), "onClientDetach3DModel", getResourceRootElement(), identifier)
end

-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
function Update3DModelAttachment(identifier, properties)
	local Instance = MODELS_ATTACHMENTS_CACHE[identifier]
	assert(Instance, "Update3DModelAttachment: Invalid identifier")

	for Property, Value in pairs(properties) do
		Instance[Property] = Value
	end

	return triggerClientEvent(getRootElement(), "onClientUpdate3DModel", getResourceRootElement(), identifier, properties)
end

-- https://www.lua.org/pil/2.5.html
function Get3DModelProperties(identifier)
	return MODELS_ATTACHMENTS_CACHE[identifier]
end

-- https://www.lua.org/pil/2.5.html
local UsefulFunctionsList = {
	["DetachALL3DModels"] = function()
		for Identifier in pairs(MODELS_ATTACHMENTS_CACHE) do
			Detach3DModelFromBone(Identifier)
		end
	end, 

	["DetachALL3DModelsFromElement"] = function(pedElement)
		for Identifier, Instance in pairs(MODELS_ATTACHMENTS_CACHE) do
			if Instance.PedElement == pedElement then
				Detach3DModelFromBone(Identifier)
			end
		end
	end, 

	["Set3DModelPed"] = function(identifier, pedElement)
		local Instance = MODELS_ATTACHMENTS_CACHE[identifier]
		assert(Instance, "Set3DModelPed: Invalid identifier")

		Instance.PedElement = pedElement
		triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "PedElement", identifier, {PedElement = pedElement}, pedElement)

		return true
	end, 

	["Set3DModelBone"] = function(identifier, bone)
		local Instance = MODELS_ATTACHMENTS_CACHE[identifier]
		assert(Instance, "Set3DModelBone: Invalid identifier")

		Instance.Bone = bone
		triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "Bone", identifier, {Bone = bone})

		return true
	end,

	["Set3DModelPositionOffset"] = function(identifier, positionOffset)
		local Instance = MODELS_ATTACHMENTS_CACHE[identifier]
		assert(Instance, "Set3DModelPositionOffset: Invalid identifier")

		Instance.Position = positionOffset
		triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "PositionOffset", identifier, {Position = positionOffset})

		return true
	end,

	["Set3DModelRotationOffset"] = function(identifier, rotationOffset)
		local Instance = MODELS_ATTACHMENTS_CACHE[identifier]
		assert(Instance, "Set3DModelRotationOffset: Invalid identifier")

		Instance.Rotation = rotationOffset
		triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "RotationOffset", identifier, {Rotation = rotationOffset})

		return true
	end,

	["Set3DModelScale"] = function(identifier, scale)
		local Instance = MODELS_ATTACHMENTS_CACHE[identifier]
		assert(Instance, "Set3DModelScale: Invalid identifier")

		Instance.Scale = scale
		triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "Scale", identifier, {Scale = scale})

		return true
	end,

	["Set3DModelVisible"] = function(identifier, visible)
		local Instance = MODELS_ATTACHMENTS_CACHE[identifier]
		assert(Instance, "Set3DModelVisible: Invalid identifier")

		Instance.Visible = visible
		triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "Visible", identifier, {Visible = visible})

		return true
	end,

	["Set3DModelVisibleAll"] = function(visible)
		for Identifier in pairs(MODELS_ATTACHMENTS_CACHE) do
			MODELS_ATTACHMENTS_CACHE[Identifier].Visible = visible
		end

		triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "VisibileAll", identifier, {Visible = visible})

		return true
	end, 

	["Set3DModelVisibleAllFromElement"] = function(pedElement)
		for Identifier, Instance in pairs(MODELS_ATTACHMENTS_CACHE) do
			if Instance.PedElement == pedElement then
				Instance.Visible = visible
			end
		end

		triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "VisibleAllFromElement", identifier, {Visible = visible}, pedElement)

		return true
	end
}

-- https://www.lua.org/pil/14.html
for FunctionName, Function in pairs(UsefulFunctionsList) do
	_G[FunctionName] = Function
end