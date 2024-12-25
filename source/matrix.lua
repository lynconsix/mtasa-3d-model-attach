-- https://wiki.multitheftauto.com/wiki/AttachElementToBone
function CreateTransformedBoneMatrix(boneMatrix, rotationMatrix, offSetX, offSetY, offSetZ)
	local BM11, BM12, BM13 = boneMatrix[1][1], boneMatrix[1][2], boneMatrix[1][3]
	local BM21, BM22, BM23 = boneMatrix[2][1], boneMatrix[2][2], boneMatrix[2][3]
	local BM31, BM32, BM33 = boneMatrix[3][1], boneMatrix[3][2], boneMatrix[3][3]
	local BM41, BM42, BM43 = boneMatrix[4][1], boneMatrix[4][2], boneMatrix[4][3]

	local RM11, RM12, RM13 = rotationMatrix[1][1], rotationMatrix[1][2], rotationMatrix[1][3]
	local RM21, RM22, RM23 = rotationMatrix[2][1], rotationMatrix[2][2], rotationMatrix[2][3]
	local RM31, RM32, RM33 = rotationMatrix[3][1], rotationMatrix[3][2], rotationMatrix[3][3]

	return {
		{
			BM21 * RM12 + BM11 * RM11 + RM13 * BM31,
			BM32 * RM13 + BM12 * RM11 + BM22 * RM12,
			BM23 * RM12 + BM33 * RM13 + RM11 * BM13,
		},
		{
			RM23 * BM31 + BM21 * RM22 + RM21 * BM11,
			BM32 * RM23 + BM22 * RM22 + BM12 * RM21,
			RM21 * BM13 + BM33 * RM23 + BM23 * RM22,
		},
		{
			BM21 * RM32 + RM33 * BM31 + RM31 * BM11,
			BM32 * RM33 + BM22 * RM32 + RM31 * BM12,
			RM31 * BM13 + BM33 * RM33 + BM23 * RM32,
		},
		{
			offSetX * BM11 + offSetY * BM21 + offSetZ * BM31 + BM41,
			offSetX * BM12 + offSetY * BM22 + offSetZ * BM32 + BM42,
			offSetX * BM13 + offSetY * BM23 + offSetZ * BM33 + BM43,
		}
	}
end

-- https://wiki.multitheftauto.com/wiki/Quaternion
local MSqrt = math.sqrt
local MDeg = math.deg

local MAsin = math.asin
local MAtan2 = math.atan2

function GetEulerAnglesFromMatrix(matrix)
	local MT21, MT22, MT23 = matrix[2][1], matrix[2][2], matrix[2][3]

	local NormZ3 = MSqrt(MT21 * MT21 + MT22 * MT22)
	local NormZ2 = -MT22 * MT23 / NormZ3
	local NormZ1 = -MT21 * MT23 / NormZ3

	local VectorX = NormZ1 * matrix[1][1] + NormZ2 * matrix[1][2] + NormZ3 * matrix[1][3]
	local VectorZ = NormZ1 * matrix[3][1] + NormZ2 * matrix[3][2] + NormZ3 * matrix[3][3]

	return MDeg(MAsin(MT23)), -MDeg(MAtan2(VectorX, VectorZ)), -MDeg(MAtan2(MT21, MT22))
end

-- https://wiki.multitheftauto.com/wiki/GetElementMatrix
local MRad = math.rad
local MCos = math.cos
local MSin = math.sin

function CalculeRotationMatrix(offRotX, offRotY, offRotZ)
	local RotX, RotY, RotZ = MRad(offRotX), MRad(offRotY), MRad(offRotZ)

	local SinYaw, CosYaw = MSin(RotX), MCos(RotX)
	local SinPitch, CosPitch = MSin(RotY), MCos(RotY)
	local SinRoll, CosRoll = MSin(RotZ), MCos(RotZ)

	return {
		{ 
			CosPitch * CosRoll - SinPitch * SinYaw * SinRoll, 
			CosPitch * SinRoll + SinPitch * SinYaw * CosRoll, 
			-SinPitch * CosYaw
		},

		{
			-CosYaw * SinRoll, 
			CosYaw * CosRoll, 
			SinYaw
		},

		{
			SinPitch * CosRoll + CosPitch * SinYaw * SinRoll, 
			SinPitch * SinRoll - CosPitch * SinYaw * CosRoll, 
			CosPitch * CosYaw
		}
	}
end

-- https://wiki.multitheftauto.com/wiki/GetElementMatrix
function GetPositionFromMatrixOffset(matrix, offX, offY, offZ)
	return 
		offX * matrix[1][1] + offY * matrix[2][1] + offZ * matrix[3][1] + matrix[4][1], 
		offX * matrix[1][2] + offY * matrix[2][2] + offZ * matrix[3][2] + matrix[4][2], 
		offX * matrix[1][3] + offY * matrix[2][3] + offZ * matrix[3][3] + matrix[4][3]
end