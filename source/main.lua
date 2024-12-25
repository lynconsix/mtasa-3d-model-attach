DX_MODELS_ATTACHMENTS = {}
DX_MODELS_STREAMING = {}

CACHE_FOR_3D_MODEL_RENDERING = {}
MODEL_CACHE_ASSIGNED_TO_STREAMING = {}

local RendererState = false

-- https://wiki.multitheftauto.com/wiki/IsElement
local function ValidElementAndKey(pedElement, key)
	if not isElement(pedElement) then
		return false, error("Invalid pedElement")
	end

	if not key then
		return false, error("Invalid key")
	end

	if not DX_MODELS_ATTACHMENTS[key] then
		return false, error("Invalid key")
	end

	return true
end

-- https://wiki.multitheftauto.com/wiki/EngineStreamingRequestModel
function Attach3DModelToBone(pedElement, key, modelId, bone, position, rotation, scale)
	if not isElement(pedElement) then
		return false, error("Attach3DModelToBone: Invalid pedElement")
	end

	if not modelId or not bone then
		return false, error("Attach3DModelToBone: Invalid arguments")
	end

	local Bone = GetBoneId(bone)

	if not Bone then
		return false, error("Attach3DModelToBone: Invalid bone")
	end

	if not DX_MODELS_STREAMING[modelId] then
		engineStreamingRequestModel(modelId, true, true)
		DX_MODELS_STREAMING[modelId] = true
	end

	local NewAttachment = {
		Drawing = true, 
		Visible = true, 

		PedElement = pedElement,
		Key = key,

		ModelId = modelId,
		Bone = Bone,

		Position = position or {0, 0, 0},
		Rotation = rotation or {0, 0, 0},

		Scale = scale or {1, 1, 1}, 
		RotationMatrix = CalculeRotationMatrix(rotation[1] or 0, rotation[2] or 0, rotation[3] or 0)
	}

	if not DX_MODELS_ATTACHMENTS[key] then
		table.insert(CACHE_FOR_3D_MODEL_RENDERING, NewAttachment)

		DX_MODELS_ATTACHMENTS[key] = NewAttachment

		table.insert(MODEL_CACHE_ASSIGNED_TO_STREAMING, modelId)
	end

	if Length(CACHE_FOR_3D_MODEL_RENDERING) == 1 and not RendererState then
		ToggleEvents(true)
	end

	return true
end

-- https://wiki.multitheftauto.com/wiki/EngineStreamingReleaseModel
function Detach3DModelFromBone(pedElement, key)
	if not isElement(pedElement) then
		return false, error("Detach3DModelFromBone: Invalid pedElement")
	end

	if not key then
		return false, error("Detach3DModelFromBone: Invalid arguments")
	end

	local Backup = DX_MODELS_ATTACHMENTS[key]

	if not Backup then
		return false, error("Detach3DModelFromBone: Attachment not found")
	end

	if Backup.PedElement ~= pedElement then
		return false, error("Detach3DModelFromBone: Attachment not found")
	end

	DX_MODELS_ATTACHMENTS[key] = nil
	CheckAttachment(Backup)

	if Length(CACHE_FOR_3D_MODEL_RENDERING) == 0 and RendererState then
		ToggleEvents(false)
	end

	return true
end

-- https://www.lua.org/pil/2.5.html
function Update3DModelAttachment(pedElement, key, properties)
	if not ValidElementAndKey(pedElement, key) then
		return false
	end

	local Backup = DX_MODELS_ATTACHMENTS[key]
	local OldModelId = Backup.ModelId

	for Property, Value in pairs(properties) do
		Backup[Property] = Value
	end

	if properties.Rotation then
		Backup.RotationMatrix = CalculeRotationMatrix(properties.Rotation[1] or 0, properties.Rotation[2] or 0, properties.Rotation[3] or 0)
	end

	if properties.ModelId then
		if not DX_MODELS_STREAMING[properties.ModelId] then
			engineStreamingRequestModel(properties.ModelId, true, true)
			DX_MODELS_STREAMING[properties.ModelId] = true
		end

		for Index = 1, #MODEL_CACHE_ASSIGNED_TO_STREAMING do
			local Value = MODEL_CACHE_ASSIGNED_TO_STREAMING[Index]

			if Value and Value == OldModelId then
				table.remove(MODEL_CACHE_ASSIGNED_TO_STREAMING, Index)

				break
			end
		end

		table.insert(MODEL_CACHE_ASSIGNED_TO_STREAMING, properties.ModelId)
	end

	return true
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

		return DX_MODELS_ATTACHMENTS[key] and DX_MODELS_ATTACHMENTS[key].PedElement == pedElement
	end,

	["DetachALL3DModels"] = function()
		for Key in pairs(DX_MODELS_ATTACHMENTS) do
			Detach3DModelFromBone(DX_MODELS_ATTACHMENTS[Key].PedElement, Key)
		end
	end,

	["DetachALL3DModelsFromElement"] = function(pedElement)
		if not isElement(pedElement) then
			return false, error("DetachALL3DModelsFromElement: Invalid pedElement")
		end

		for Key, Value in pairs(DX_MODELS_ATTACHMENTS) do
			Detach3DModelFromBone(pedElement, Key)
		end
	end, 

	["Set3DModelBone"] = function(pedElement, key, bone)
		if not ValidElementAndKey(pedElement, key) then
			return false
		end

		local Bone = GetBoneId(bone)

		if not Bone then
			return false, error("Set3DModelBone: Invalid bone")
		end

		local Backup = DX_MODELS_ATTACHMENTS[key]

		if Backup.PedElement ~= pedElement then
			return false, error("Set3DModelBone: Attachment not found")
		end

		Update3DModelAttachment(Backup.PedElement, key, {Bone = Bone})

		return true
	end, 

	["Set3DModelPositionOffset"] = function(pedElement, key, position)
		if not ValidElementAndKey(pedElement, key) then
			return false
		end

		local Backup = DX_MODELS_ATTACHMENTS[key]

		if Backup.PedElement ~= pedElement then
			return false, error("Set3DModelPositionOffset: Attachment not found")
		end

		Update3DModelAttachment(Backup.PedElement, key, {Position = position})

		return true
	end, 

	["Set3DModelRotationOffset"] = function(pedElement, key, rotation)
		if not ValidElementAndKey(pedElement, key) then
			return false
		end

		local Backup = DX_MODELS_ATTACHMENTS[key]

		if Backup.PedElement ~= pedElement then
			return false, error("Set3DModelRotationOffset: Attachment not found")
		end

		Update3DModelAttachment(Backup.PedElement, key, {Rotation = rotation})

		return true
	end, 

	["Set3DModelScale"] = function(pedElement, key, scale)
		if not ValidElementAndKey(pedElement, key) then
			return false
		end

		local Backup = DX_MODELS_ATTACHMENTS[key]

		if Backup.PedElement ~= pedElement then
			return false, error("Set3DModelScale: Attachment not found")
		end

		Update3DModelAttachment(Backup.PedElement, key, {Scale = scale})

		return true
	end, 

	["Set3DModelPed"] = function(pedElement, key, newPedElement)
		if not ValidElementAndKey(pedElement, key) then
			return false
		end

		Update3DModelAttachment(pedElement, key, {PedElement = newPedElement})

		return true
	end, 

	["Set3DModelVisible"] = function(pedElement, key, state)
		if not ValidElementAndKey(pedElement, key) then
			return false
		end

		local Backup = DX_MODELS_ATTACHMENTS[key]

		if Backup.PedElement ~= pedElement then
			return false, error("Set3DModelVisible: Attachment not found")
		end

		Update3DModelAttachment(Backup.PedElement, key, {Visible = state})

		return true
	end, 

	["Set3DModelVisibleAll"] = function(state)
		if state == nil then
			return false, error("Set3DModelVisibleAll: Invalid arguments")
		end

		for Key, Value in pairs(DX_MODELS_ATTACHMENTS) do
			Update3DModelAttachment(Value.PedElement, Key, {Visible = state})
		end

		return true
	end, 

	["Get3DModelAttachmentProperties"] = function(pedElement, key)
		if not isElement(pedElement) then
			return false, error("Get3DModelAttachmentProperties: Invalid pedElement")
		end

		if not key then
			return false, error("Get3DModelAttachmentProperties: Invalid arguments")
		end

		local Backup = DX_MODELS_ATTACHMENTS[key]

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

-- https://www.lua.org/pil/2.5.html
function CheckAttachment(backup)
	if not backup then
		return false, error("CheckAttachment: Invalid arguments")
	end

	for Index = #CACHE_FOR_3D_MODEL_RENDERING, 1, -1 do
		local Value = CACHE_FOR_3D_MODEL_RENDERING[Index]

		if Value and Value.PedElement == backup.PedElement and Value.Key == backup.Key then
			table.remove(CACHE_FOR_3D_MODEL_RENDERING, Index)
		end
	end

	if Length(MODEL_CACHE_ASSIGNED_TO_STREAMING) ~= 0 then
		local ModelCountList = CountModelOccurrences(MODEL_CACHE_ASSIGNED_TO_STREAMING)

		for Index = 1, #MODEL_CACHE_ASSIGNED_TO_STREAMING do
			local Value = MODEL_CACHE_ASSIGNED_TO_STREAMING[Index]

			if Value and Value == backup.ModelId then
				table.remove(MODEL_CACHE_ASSIGNED_TO_STREAMING, Index)
				ModelCountList[Value] = ModelCountList[Value] - 1

				if ModelCountList[Value] == 0 then
					engineStreamingReleaseModel(Value, true)
					ModelCountList[Value] = nil
				end
			end
		end
	end

	if Length(MODEL_CACHE_ASSIGNED_TO_STREAMING) == 0 then
		for ModelId in pairs(DX_MODELS_STREAMING) do
			engineStreamingReleaseModel(ModelId, true)
			DX_MODELS_STREAMING[ModelId] = nil
		end
	end

	return true
end

-- https://wiki.multitheftauto.com/wiki/DxDrawModel3D
local IsElementOnScreen = isElementOnScreen

local GetElementPosition = getElementPosition
local GetElementRotation = getElementRotation

local GetElementBoneMatrix = getElementBoneMatrix
local GetPedBonePosition = getPedBonePosition

local DxDrawModel3D = dxDrawModel3D

-- https://wiki.multitheftauto.com/wiki/OnClientPreRender
local TransformedBoneMatrix
local EulerX, EulerY, EulerZ
local OffsetX, OffsetY, OffsetZ

local function OnClientPreRender()
	local BoneMatrixCache = {}

	for Index = 1, #CACHE_FOR_3D_MODEL_RENDERING do
		local Value = CACHE_FOR_3D_MODEL_RENDERING[Index]

		if Value and Value.Visible then
			local PedElement = Value.PedElement

			if IsElementOnScreen(PedElement) then
				local Bone = Value.Bone

				local BoneMatrixBackup = BoneMatrixCache[PedElement]
				local BoneMatrix

				if not BoneMatrixBackup then
					BoneMatrixBackup = {}
					BoneMatrixCache[PedElement] = BoneMatrixBackup
				end

				if not BoneMatrixBackup[Bone] then
					BoneMatrix = GetElementBoneMatrix(PedElement, Bone)
					BoneMatrixBackup[Bone] = BoneMatrix
				else
					BoneMatrix = BoneMatrixBackup[Bone]
				end

				if BoneMatrix then
					Value.Drawing = true

					local ModelId = Value.ModelId
					local RotationMatrix = Value.RotationMatrix

					local PositionX, PositionY, PositionZ = Value.Position[1], Value.Position[2], Value.Position[3]
					local ScaleX, ScaleY, ScaleZ = Value.Scale[1], Value.Scale[2], Value.Scale[3]

					TransformedBoneMatrix = CreateTransformedBoneMatrix(BoneMatrix, RotationMatrix, PositionX, PositionY, PositionZ)
					EulerX, EulerY, EulerZ = GetEulerAnglesFromMatrix(TransformedBoneMatrix)
					OffsetX, OffsetY, OffsetZ = GetPositionFromMatrixOffset(TransformedBoneMatrix, 0, 0, 0)

					DxDrawModel3D(
						ModelId, 
						OffsetX, OffsetY, OffsetZ, 
						EulerX, EulerY, EulerZ, 
						ScaleX, ScaleY, ScaleZ
					)
				end
			else
				if Value.Drawing then
					Value.Drawing = false
				end
			end
		end
	end
end

-- https://wiki.multitheftauto.com/wiki/AddEventHandler / https://wiki.multitheftauto.com/wiki/RemoveEventHandler
function ToggleEvents(state)
	local RemoteEvent = state and addEventHandler or removeEventHandler

	RendererState = state
	RemoteEvent("onClientPreRender", getRootElement(), OnClientPreRender)
end