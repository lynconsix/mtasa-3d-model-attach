# 3d model attach
This resource has been developed to replace the **bone_attach** resources, making this resource much more useful as it will not be necessary to use `createObject` to attach to the bone (bone_attach). 

# Documentation
You can find the documentation on Wiki page. [(click here)](https://github.com/lynconsix/mtasa-3d-model-attach/wiki)

# How to use
\- On the server side, here is an example of using multiple ids:

```lua
addCommandHandler("testdxmodel", 
	function(player)
		Attach3DModelToBone(player, 355, "BONE_HANDWEAPON", {.1, 0, 0}, {0, 0, 0})
		Attach3DModelToBone(player, 355, 34, {0.02, 0.05, 0}, {20, 190, 190})

		local Back = Attach3DModelToBone(player, 371, "BONE_SPINE1BACKPACK", {0, -.15, 0}, {0, 90, 0})

		Attach3DModelToBone(player, 372, 41, {-0.05, -0.06, -0.03}, {-72, 10.8, 25.2})
		Attach3DModelToBone(player, 363, 51, {0.04, -0.21, 0.11}, {-82.8, -86.4, 0})
		Attach3DModelToBone(player, 359, 3, {-0.08, 0.21, -0.11}, {165.6, 147.6, 0})

		local Attt = Attach3DModelToBone(player, 1238, "BONE_HEAD", {-0.01, -0.29, 0.08}, {75.6, 0, 0}, {.5, .5, .5})

		setTimer(Detach3DModelFromBone, 2000, 1, Attt)

		local Px, Py, Pz = getElementPosition(player)
		local PedElement = createPed(0, Px, Py, Pz)

		setTimer(Set3DModelPed, 4000, 1, Back, PedElement)
	end
)
```

<img src="https://i.imgur.com/BpsS9Ra.png">

# Is it possible to use [engineRequetModel](https://wiki.multitheftauto.com/wiki/EngineRequestModel)?
Yes, but you have to be very careful when using it, because if you have a problem with the [engineRequestModel](https://wiki.multitheftauto.com/wiki/EngineRequestModel) your MTA:SA is likely to crash

Aqui um exemplo do uso do **engineRequetModel**:

```lua
local NewId = engineRequestModel("object")

addEventHandler("onClientResourceStop", resourceRoot, 
	function()
		engineFreeModel(NewId)
	end
)

addCommandHandler("testdxmodel", 
	function()
		Attach3DModelToBone(localPlayer, NewId, "BONE_HEAD", {-0.01, -0.29, 0.08}, {75.6, 0, 0}, {.5, .5, .5})
	end
)
```

Remember that this is just an example of using the **EngineRequestModel**.

<img src="https://i.imgur.com/aC9swWA.png">