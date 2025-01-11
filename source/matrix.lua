-- https://wiki.multitheftauto.com/wiki/AttachElementToBone
function CreateTransformedBoneMatrix(boneMatrix, rotationMatrix, offSetX, offSetY, offSetZ)
	local BoneMatrix1, BoneMatrix2, BoneMatrix3, BoneMatrix4 = boneMatrix[1], boneMatrix[2], boneMatrix[3], boneMatrix[4]
	local RotationMatrix1, RotationMatrix2, RotationMatrix3 = rotationMatrix[1], rotationMatrix[2], rotationMatrix[3]

	return {
		{
			BoneMatrix1[1] * RotationMatrix1[1] + BoneMatrix2[1] * RotationMatrix1[2] + BoneMatrix3[1] * RotationMatrix1[3],
			BoneMatrix1[2] * RotationMatrix1[1] + BoneMatrix2[2] * RotationMatrix1[2] + BoneMatrix3[2] * RotationMatrix1[3],
			BoneMatrix1[3] * RotationMatrix1[1] + BoneMatrix2[3] * RotationMatrix1[2] + BoneMatrix3[3] * RotationMatrix1[3],
		},

		{
			BoneMatrix1[1] * RotationMatrix2[1] + BoneMatrix2[1] * RotationMatrix2[2] + BoneMatrix3[1] * RotationMatrix2[3],
			BoneMatrix1[2] * RotationMatrix2[1] + BoneMatrix2[2] * RotationMatrix2[2] + BoneMatrix3[2] * RotationMatrix2[3],
			BoneMatrix1[3] * RotationMatrix2[1] + BoneMatrix2[3] * RotationMatrix2[2] + BoneMatrix3[3] * RotationMatrix2[3],
		},

		{
			BoneMatrix1[1] * RotationMatrix3[1] + BoneMatrix2[1] * RotationMatrix3[2] + BoneMatrix3[1] * RotationMatrix3[3],
			BoneMatrix1[2] * RotationMatrix3[1] + BoneMatrix2[2] * RotationMatrix3[2] + BoneMatrix3[2] * RotationMatrix3[3],
			BoneMatrix1[3] * RotationMatrix3[1] + BoneMatrix2[3] * RotationMatrix3[2] + BoneMatrix3[3] * RotationMatrix3[3],
		},

		{
			offSetX * BoneMatrix1[1] + offSetY * BoneMatrix2[1] + offSetZ * BoneMatrix3[1] + BoneMatrix4[1],
			offSetX * BoneMatrix1[2] + offSetY * BoneMatrix2[2] + offSetZ * BoneMatrix3[2] + BoneMatrix4[2],
			offSetX * BoneMatrix1[3] + offSetY * BoneMatrix2[3] + offSetZ * BoneMatrix3[3] + BoneMatrix4[3],
		}
	}
end

-- https://wiki.multitheftauto.com/wiki/Quaternion
local MSqrt, MDeg, MAsin, MAtan2 = math.sqrt, math.deg, math.asin, math.atan2

function GetEulerAnglesFromMatrix(matrix)
	local MT21, MT22, MT23 = matrix[2][1], matrix[2][2], matrix[2][3]

	local NormZ3 = MSqrt(MT21 * MT21 + MT22 * MT22)
	local NormZ1, NormZ2 = -MT21 * MT23 / NormZ3, -MT22 * MT23 / NormZ3

	local VectorX = NormZ1 * matrix[1][1] + NormZ2 * matrix[1][2] + NormZ3 * matrix[1][3]
	local VectorZ = NormZ1 * matrix[3][1] + NormZ2 * matrix[3][2] + NormZ3 * matrix[3][3]

	return MDeg(MAsin(MT23)), -MDeg(MAtan2(VectorX, VectorZ)), -MDeg(MAtan2(MT21, MT22))
end

-- https://wiki.multitheftauto.com/wiki/GetElementMatrix
local MRad, MSin, MCos = math.rad, math.sin, math.cos

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
	return {
		offX * matrix[1][1] + offY * matrix[2][1] + offZ * matrix[3][1] + matrix[4][1], 
		offX * matrix[1][2] + offY * matrix[2][2] + offZ * matrix[3][2] + matrix[4][2], 
		offX * matrix[1][3] + offY * matrix[2][3] + offZ * matrix[3][3] + matrix[4][3]
	}
end