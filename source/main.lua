DX_MODELS_REFERENCES = {}
DX_MODELS_INSTANCES = {}

DX_MODELS_STREAMING = {}

DX_MODELS_RENDERED_CACHE = {}
DX_MODEL_CACHE_ASSIGNED_TO_STREAMING = {}

-- https://wiki.multitheftauto.com/wiki/IsElement
function IsModel3DAttached(model3DElement)
	return (model3DElement and DX_MODELS_INSTANCES[model3DElement]) and true or false
end

-- https://wiki.multitheftauto.com/wiki/EngineStreamingRequestModel
function Attach3DModelToBone(pedElement, modelId, bone, position, rotation, scale)
	local Bone = GetBoneId(bone)
	local ElementType = getElementType(pedElement)

	assert(isElement(pedElement), "Bad argument @ 'Attach3DModelToBone' [expected element at argument 1, got " .. type(pedElement) .. "]")
	assert(Bone, "Bad argument @ 'Attach3DModelToBone' [invalid bone at argument 3]")
	assert(ElementType == "ped" or ElementType == "player", "Bad argument @ 'Attach3DModelToBone' [expected ped/player at argument 1, got " .. ElementType .. "]")

	local RegisterId = FindEmptyEntry(DX_MODELS_REFERENCES)
	local NewElement = createElement("3dmodelattachment", tostring(RegisterId))

	if not DX_MODELS_STREAMING[modelId] then
		engineStreamingRequestModel(modelId, true, true)
		DX_MODELS_STREAMING[modelId] = true
	end

	local Instance = {}

	Instance.Drawing = true
	Instance.Visible = true

	Instance.PedElement = pedElement

	Instance.ModelId = modelId
	Instance.Bone = Bone

	Instance.Position = position or {0, 0, 0}
	Instance.Rotation = rotation or {0, 0, 0}
	Instance.Scale = scale or {0, 0, 0}

	Instance.RotationMatrix = CalculeRotationMatrix(Instance.Rotation[1], Instance.Rotation[2], Instance.Rotation[3])

	table.insert(DX_MODELS_RENDERED_CACHE, Instance)
	table.insert(DX_MODEL_CACHE_ASSIGNED_TO_STREAMING, modelId)

	DX_MODELS_REFERENCES[RegisterId] = {Element = NewElement, Instance = Instance}
	DX_MODELS_INSTANCES[NewElement] = pedElement

	if Length(DX_MODELS_RENDERED_CACHE) == 1 then
		ToggleEvents(true)
	end

	return NewElement
end

-- https://wiki.multitheftauto.com/wiki/DestroyElement
function Detach3DModelFromBone(model3DElementOrId)
	local Reference, RegisterId = Get3DModelProperties(model3DElementOrId)

	if not Reference then
		return false
	end

	local Instance = Reference.Instance
	local Element = Reference.Element

	DX_MODELS_REFERENCES[RegisterId].Element = nil
	DX_MODELS_REFERENCES[RegisterId].Instance = nil

	CheckAttachment(Instance)
	destroyElement(Element)

	if Length(DX_MODELS_RENDERED_CACHE) == 0 then
		ToggleEvents(false)
	end

	return true
end

-- https://www.lua.org/pil/2.5.html
function Update3DModelAttachment(model3DElementOrId, properties)
	local Reference, RegisterId = Get3DModelProperties(model3DElementOrId)

	if not Reference then
		return false
	end

	local Instance = Reference.Instance

	for Property, Value in pairs(properties) do
		Instance[Property] = Value
	end

	if properties.Bone then
		Instance.Bone = GetBoneId(properties.Bone)
	end

	if properties.Rotation then
		Instance.RotationMatrix = CalculeRotationMatrix(properties.Rotation[1] or 0, properties.Rotation[2] or 0, properties.Rotation[3] or 0)
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

	DX_MODELS_RENDERED_CACHE[RegisterId] = Instance

	return true
end

-- https://www.lua.org/pil/2.5.html
function Get3DModelProperties(model3DElementOrId)
	if isElement(model3DElementOrId) and IsModel3DAttached(model3DElementOrId) then
		local RegisterId = tonumber(getElementID(model3DElementOrId))
		return DX_MODELS_REFERENCES[RegisterId] or false, RegisterId
	else
		return DX_MODELS_REFERENCES[model3DElementOrId] or false, model3DElementOrId
	end
end

-- https://www.lua.org/pil/2.5.html
local UsefulFunctionsList = {
	["DetachALL3DModels"] = function()
		for RegisterId = 1, #DX_MODELS_REFERENCES do
			local Value = DX_MODELS_REFERENCES[RegisterId]

			if Value.Element and isElement(Value.Element) then
				Detach3DModelFromBone(Value.Element)
			end
		end
	end, 

	["DetachALL3DModelsFromElement"] = function(pedElement)
		for RegisterId = 1, #DX_MODELS_REFERENCES do
			local Value = DX_MODELS_REFERENCES[RegisterId]

			if Value.Instance.PedElement == pedElement then
				if Value.Element and isElement(Value.Element) then
					Detach3DModelFromBone(Value.Element)
				end
			end
		end
	end, 

	["Set3DModelPed"] = function(model3DElement, pedElement)
		return Update3DModelAttachment(model3DElement, {PedElement = pedElement})
	end, 

	["Set3DModelBone"] = function(model3DElementOrId, bone)
		return Update3DModelAttachment(model3DElementOrId, {Bone = bone})
	end, 

	["Set3DModelPositionOffset"] = function(model3DElementOrId, position)
		return Update3DModelAttachment(model3DElementOrId, {Position = position})
	end, 

	["Set3DModelRotationOffset"] = function(model3DElementOrId, rotation)
		return Update3DModelAttachment(model3DElementOrId, {Rotation = rotation})
	end, 

	["Set3DModelScale"] = function(model3DElementOrId, scale)
		return Update3DModelAttachment(model3DElementOrId, {Scale = scale})
	end, 

	["Set3DModelVisible"] = function(model3DElementOrId, visible)
		return Update3DModelAttachment(model3DElementOrId, {Visible = visible})
	end, 

	["Set3DModelVisibleAll"] = function(pedElement, visible)
		for RegisterId = 1, #DX_MODELS_REFERENCES do
			local Value = DX_MODELS_REFERENCES[RegisterId]

			if Value.Instance and Value.Instance.PedElement == pedElement then
				Update3DModelAttachment(RegisterId, {Visible = visible})
			end
		end

		return true
	end, 

	["Set3DModelVisibleAllFromElement"] = function(pedElement, visible)
		for RegisterId = 1, #DX_MODELS_REFERENCES do
			local Value = DX_MODELS_REFERENCES[RegisterId]

			if Value.Instance and Value.Instance.PedElement == pedElement then
				Update3DModelAttachment(RegisterId, {Visible = visible})
			end
		end

		return true
	end
}

-- https://www.lua.org/pil/14.html
for FunctionName, Function in pairs(UsefulFunctionsList) do
	_G[FunctionName] = Function
end

-- https://www.lua.org/pil/2.5.html
function CheckAttachment(instance)
	for Index = #DX_MODELS_RENDERED_CACHE, 1, -1 do
		local Value = DX_MODELS_RENDERED_CACHE[Index]

		if Value and Value.PedElement == instance.PedElement and Value.Element == instance.Element and Value.ModelId == instance.ModelId then
			table.remove(DX_MODELS_RENDERED_CACHE, Index)
		end
	end

	if Length(DX_MODEL_CACHE_ASSIGNED_TO_STREAMING) ~= 0 then
		local ModelCountList = CountModelOccurrences(DX_MODEL_CACHE_ASSIGNED_TO_STREAMING)

		for Index = 1, #DX_MODEL_CACHE_ASSIGNED_TO_STREAMING do
			local Value = DX_MODEL_CACHE_ASSIGNED_TO_STREAMING[Index]

			if Value and Value == instance.ModelId then
				table.remove(DX_MODEL_CACHE_ASSIGNED_TO_STREAMING, Index)
				ModelCountList[Value] = ModelCountList[Value] - 1

				if ModelCountList[Value] == 0 then
					engineStreamingReleaseModel(Value)
					ModelCountList[Value] = nil
				end
			end
		end
	end

	if Length(DX_MODEL_CACHE_ASSIGNED_TO_STREAMING) == 0 then
		for ModelId in pairs(DX_MODELS_STREAMING) do
			engineStreamingReleaseModel(ModelId, true)
			DX_MODELS_STREAMING[ModelId] = nil
		end

		DX_MODELS_REFERENCES = {}
	end
end

-- https://wiki.multitheftauto.com/wiki/DxDrawModel3D
local IsElementOnScreen = isElementOnScreen

local GetElementPosition = getElementPosition
local GetElementRotation = getElementRotation

local GetElementBoneMatrix = getElementBoneMatrix
local GetPedBonePosition = getPedBonePosition

local DxDrawModel3D = dxDrawModel3D

-- https://wiki.multitheftauto.com/wiki/OnClientPedsProcessed
local TransformedBoneMatrix
local EulerX, EulerY, EulerZ
local OffsetX, OffsetY, OffsetZ

local function OnClientPedsProcessed()
	local BoneMatrixCache = {}

	for Index = 1, #DX_MODELS_RENDERED_CACHE do
		local Value = DX_MODELS_RENDERED_CACHE[Index]

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

					local Position = Value.Position
					local Scale = Value.Scale

					TransformedBoneMatrix = CreateTransformedBoneMatrix(BoneMatrix, Value.RotationMatrix, Position[1], Position[2], Position[3])
					EulerX, EulerY, EulerZ = GetEulerAnglesFromMatrix(TransformedBoneMatrix)
					MatrixOffset = GetPositionFromMatrixOffset(TransformedBoneMatrix, 0, 0, 0)

					DxDrawModel3D(
						Value.ModelId, 
						MatrixOffset[1], MatrixOffset[2], MatrixOffset[3], 
						EulerX, EulerY, EulerZ, 
						Scale[1], Scale[2], Scale[3]
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
	RemoteEvent("onClientPedsProcessed", getRootElement(), OnClientPedsProcessed)
end