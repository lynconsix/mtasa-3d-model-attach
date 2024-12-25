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

-- https://wiki.multitheftauto.com/wiki/IsElement
local function ValidElementAndKey(pedElement, key)
	if not isElement(pedElement) then
		return false, error("Invalid pedElement")
	end

	if not key then
		return false, error("Invalid key")
	end

	if not MODELS_ATTACHMENTS_CACHE[key] then
		return false, error("Invalid key")
	end

	return true
end

-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
function Attach3DModelToBone(pedElement, key, modelId, bone, position, rotation, scale)
	if not isElement(pedElement) then
		return false, error("Attach3DModelToBone: Invalid pedElement")
	end

	if not modelId or not bone then
		return false, error("Attach3DModelToBone: Invalid arguments")
	end

	if not MODELS_ATTACHMENTS_CACHE[key] then
		MODELS_ATTACHMENTS_CACHE[key] = {
			Visible = true,

			PedElement = pedElement,
			Key = key,

			ModelId = modelId,
			Bone = bone,

			Position = position or {0, 0, 0},
			Rotation = rotation or {0, 0, 0},

			Scale = scale or {1, 1, 1}
		}
	end

	return triggerClientEvent(getRootElement(), "onClientAttach3DModel", getResourceRootElement(), pedElement, key, modelId, bone, position, rotation, scale)
end

-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
function Detach3DModelFromBone(pedElement, key)
	if not isElement(pedElement) then
		return false, error("Detach3DModelFromBone: Invalid pedElement")
	end

	if not key then
		return false, error("Detach3DModelFromBone: Invalid arguments")
	end

	if MODELS_ATTACHMENTS_CACHE[key].PedElement ~= pedElement then
		return false, error("Detach3DModelFromBone: Attachment not found")
	end

	if MODELS_ATTACHMENTS_CACHE[key] then
		MODELS_ATTACHMENTS_CACHE[key] = nil
	end

	return triggerClientEvent(getRootElement(), "onClientDetach3DModel", getResourceRootElement(), pedElement, key)
end

-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
function Update3DModelAttachment(pedElement, key, properties)
	if not ValidElementAndKey(pedElement, key) then
		return false
	end

	for Property, Value in pairs(properties) do
		MODELS_ATTACHMENTS_CACHE[key][Property] = Value
	end

	return triggerClientEvent(getRootElement(), "onClientUpdate3DModel", getResourceRootElement(), pedElement, key, properties)
end

-- https://www.lua.org/pil/2.5.html
local UsefulFunctionsList = {
	["Is3DModelAttachedToBone"] = function(pedElement, key)
		if not isElement(pedElement) then
			return false, error("Is3DModelAttachedToBone: Invalid pedElement")
		end

		if not key then
			return false, error("Is3DModelAttachedToBone: Invalid arguments")
		end

		return MODELS_ATTACHMENTS_CACHE[key] and MODELS_ATTACHMENTS_CACHE[key].PedElement == pedElement
	end, 

	["DetachALL3DModels"] = function()
		for Key, Value in pairs(MODELS_ATTACHMENTS_CACHE) do
			Detach3DModelFromBone(Value.PedElement, Key)
		end
	end, 

	["DetachALL3DModelsFromElement"] = function(pedElement)
		if not isElement(pedElement) then
			return false, error("DetachALL3DModelsFromElement: Invalid pedElement")
		end

		for Key, Value in pairs(MODELS_ATTACHMENTS_CACHE) do
			Detach3DModelFromBone(pedElement, Key)
		end
	end, 

	["Set3DModelBone"] = function(pedElement, key, bone)
		if not ValidElementAndKey(pedElement, key) then
			return false
		end

		MODELS_ATTACHMENTS_CACHE[key].Bone = bone
		return triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "Bone", pedElement, key, {Bone = bone})
	end, 

	["Set3DModelPositionOffset"] = function(pedElement, key, position)
		if not ValidElementAndKey(pedElement, key) then
			return false
		end

		MODELS_ATTACHMENTS_CACHE[key].Position = position
		return triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "PositionOffset", pedElement, key, {Position = position})
	end, 

	["Set3DModelRotationOffset"] = function(pedElement, key, rotation)
		if not ValidElementAndKey(pedElement, key) then
			return false
		end

		MODELS_ATTACHMENTS_CACHE[key].Rotation = rotation
		return triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "RotationOffset", pedElement, key, {Rotation = rotation})
	end, 

	["Set3DModelScale"] = function(pedElement, key, scale)
		if not ValidElementAndKey(pedElement, key) then
			return false
		end

		MODELS_ATTACHMENTS_CACHE[key].Scale = scale
		return triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "Scale", pedElement, key, {Scale = scale})
	end, 

	["Set3DModelPed"] = function(pedElement, key, newPedElement)
		if not isElement(pedElement) then
			return false, error("Set3DModelPed: Invalid pedElement")
		end

		if not key or not isElement(newPedElement) then
			return false, error("Set3DModelPed: Invalid arguments")
		end

		if not MODELS_ATTACHMENTS_CACHE[key] then
			return false, error("Set3DModelPed: Attachment not found")
		end

		Update3DModelAttachment(pedElement, key, {PedElement = newPedElement})

		return true
	end, 

	["Set3DModelVisible"] = function(pedElement, key, state)
		if not ValidElementAndKey(pedElement, key) then
			return false
		end

		MODELS_ATTACHMENTS_CACHE[key].Visible = state
		return triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "Visible", pedElement, key, {Visible = state})
	end, 

	["Set3DModelVisibleAll"] = function(state)
		for Key, Value in pairs(MODELS_ATTACHMENTS_CACHE) do
			Value.Visible = state

			triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "VisibleAll", Value.PedElement, Key, {Visible = state})
		end
	end, 

	["Set3DModelVisibleAllFromElement"] = function(pedElement, state)
		for Key, Value in pairs(MODELS_ATTACHMENTS_CACHE) do
			if Value.PedElement == pedElement then
				Value.Visible = state

				triggerClientEvent(getRootElement(), "onClientUsefulUpdate3DModel", getResourceRootElement(), "VisibleAllFromElement", pedElement, Key, {Visible = state})
			end
		end
	end, 

	["Get3DModelAttachmentProperties"] = function(pedElement, key)
		if not isElement(pedElement) then
			return false, error("Get3DModelAttachmentProperties: Invalid pedElement")
		end

		if not key then
			return false, error("Get3DModelAttachmentProperties: Invalid arguments")
		end

		local Backup = MODELS_ATTACHMENTS_CACHE[key]

		if not Backup then
			return false, error("Get3DModelAttachmentProperties: Attachment not found")
		end

		if Backup.PedElement ~= pedElement then
			return false, error("Get3DModelAttachmentProperties: Attachment not found")
		end

		return Backup
	end
}

-- https://www.lua.org/pil/14.html
for FunctionName, Function in pairs(UsefulFunctionsList) do
	_G[FunctionName] = Function
end