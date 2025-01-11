-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
addEvent("onClientCustomReceiveCache", true)
addEventHandler("onClientCustomReceiveCache", getResourceRootElement(), 
	function(attachmentsCache)
		-- https://wiki.multitheftauto.com/wiki/TriggerClientEvent
		for Key, Value in pairs(attachmentsCache) do
			Attach3DModelToBone(Value.PedElement, Value.ModelId, Value.Bone, Value.Position, Value.Rotation, Value.Scale)
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
			function(triggerName, identifier, properties, ...)
				if triggerName == "PedElement" then
					Set3DModelPed(identifier, ...)

				elseif triggerName == "Bone" then
					Set3DModelBone(identifier, properties.Bone)

				elseif triggerName == "PositionOffset" then
					Set3DModelPositionOffset(identifier, properties.PositionOffset)

				elseif triggerName == "RotationOffset" then
					Set3DModelRotationOffset(identifier, properties.RotationOffset)

				elseif triggerName == "Scale" then
					Set3DModelScale(identifier, properties.Scale)

				elseif triggerName == "Visible" then
					Set3DModelVisible(identifier, properties.Visible)

				elseif triggerName == "VisibleAll" then
					Set3DModelVisibleAll(properties.Visible)

				elseif triggerName == "VisibleAllFromElement" then
					Set3DModelVisibleAllFromElement(properties.Visible, ...)
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

		for Index = 1, #DX_MODEL_CACHE_ASSIGNED_TO_STREAMING do
			table.remove(DX_MODEL_CACHE_ASSIGNED_TO_STREAMING, Index)
			DX_MODEL_CACHE_ASSIGNED_TO_STREAMING[Index] = nil
		end

		for RegisterId = 1, #DX_MODELS_REFERENCES do
			local Value = DX_MODELS_REFERENCES[RegisterId]

			if Value.Element and isElement(Value.Element) then
				destroyElement(Value.Element)
			end

			DX_MODELS_REFERENCES[RegisterId] = nil
		end
	end
)