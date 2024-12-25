-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
addEvent("onClientCustomReceiveCache", true)
addEventHandler("onClientCustomReceiveCache", getResourceRootElement(), 
	function(attachmentsCache)
		-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
		for Key, Value in pairs(attachmentsCache) do
			Attach3DModelToBone(Value.PedElement, Value.Key, Value.ModelId, Value.Bone, Value.Position, Value.Rotation, Value.Scale)
		end

		-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
		addEvent("onClientAttach3DModel", true)
		addEventHandler("onClientAttach3DModel", getResourceRootElement(), Attach3DModelToBone)

		-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
		addEvent("onClientDetach3DModel", true)
		addEventHandler("onClientDetach3DModel", getResourceRootElement(), Detach3DModelFromBone)

		-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
		addEvent("onClientUpdate3DModel", true)
		addEventHandler("onClientUpdate3DModel", getResourceRootElement(), Update3DModelAttachment)

		-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
		addEvent("onClientUsefulUpdate3DModel", true)
		addEventHandler("onClientUsefulUpdate3DModel", getResourceRootElement(), 
			function(identifier, pedElement, key, properties)
				if identifier == "Bone" then
					Set3DModelBone(pedElement, key, properties.Bone)
				elseif identifier == "PositionOffset" then
					Set3DModelPositionOffset(pedElement, key, properties.PositionOffset)
				elseif identifier == "RotationOffset" then
					Set3DModelRotationOffset(pedElement, key, properties.RotationOffset)
				elseif identifier == "Scale" then
					Set3DModelScale(pedElement, key, properties.Scale)
				elseif identifier == "Visible" then
					Set3DModelVisible(pedElement, key, properties.Visible)
				elseif identifier == "VisibleAll" then
					Set3DModelVisibleAll(pedElement, properties.Visible)
				end
			end
		)
	end
)

-- https://wiki.multitheftauto.com/wiki/EngineStreamingReleaseModel
addEventHandler("onClientResourceStop", getResourceRootElement(), 
	function()
		for ModelId in pairs(DX_MODELS_STREAMING) do
			engineStreamingReleaseModel(ModelId, true)
			DX_MODELS_STREAMING[ModelId] = nil
		end

		for Index = 1, #MODEL_CACHE_ASSIGNED_TO_STREAMING do
			table.remove(MODEL_CACHE_ASSIGNED_TO_STREAMING, Index)
			MODEL_CACHE_ASSIGNED_TO_STREAMING[Index] = nil
		end
	end
)