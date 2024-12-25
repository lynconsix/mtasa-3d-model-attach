-- https://wiki.multitheftauto.com/wiki/Bone_IDs
VALID_BONE_IDS = {
	[0] = "BONE_ROOT",
	[1] = "BONE_PELVIS1",
	[2] = "BONE_PELVIS",
	[3] = "BONE_SPINE1",
	[4] = "BONE_UPPERTORSO",
	[5] = "BONE_NECK",
	[6] = "BONE_HEAD2",
	[7] = "BONE_HEAD1",
	[8] = "BONE_HEAD",
	[22] = "BONE_RIGHTSHOULDER",
	[23] = "BONE_RIGHTELBOW",
	[24] = "BONE_RIGHTWRIST",
	[25] = "BONE_RIGHTHAND",
	[26] = "BONE_RIGHTTHUMB",
	[31] = "BONE_LEFTUPPERTORSO",
	[32] = "BONE_LEFTSHOULDER",
	[33] = "BONE_LEFTELBOW",
	[34] = "BONE_LEFTWRIST",
	[35] = "BONE_LEFTHAND",
	[36] = "BONE_LEFTTHUMB",
	[41] = "BONE_LEFTHIP",
	[42] = "BONE_LEFTKNEE",
	[43] = "BONE_LEFTANKLE",
	[44] = "BONE_LEFTFOOT",
	[51] = "BONE_RIGHTHIP",
	[52] = "BONE_RIGHTKNEE",
	[53] = "BONE_RIGHTANKLE",
	[54] = "BONE_RIGHTFOOT",
	[201] = "BONE_BELLY",
	[301] = "BONE_RIGHTBREAST",
	[302] = "BONE_LEFTBREAST",
}

-- https://wiki.multitheftauto.com/wiki/Bone_IDs
VALID_BONE_NAMES_BY_ID = {
	["BONE_ROOT"] = 0,
	["BONE_PELVIS1"] = 1,
	["BONE_PELVIS"] = 2,
	["BONE_SPINE1"] = 3,
	["BONE_UPPERTORSO"] = 4,
	["BONE_NECK"] = 5,
	["BONE_HEAD2"] = 6,
	["BONE_HEAD1"] = 7,
	["BONE_HEAD"] = 8,
	["BONE_RIGHTSHOULDER"] = 22,
	["BONE_RIGHTELBOW"] = 23,
	["BONE_RIGHTWRIST"] = 24,
	["BONE_RIGHTHAND"] = 25,
	["BONE_RIGHTTHUMB"] = 26,
	["BONE_LEFTUPPERTORSO"] = 31,
	["BONE_LEFTSHOULDER"] = 32,
	["BONE_LEFTELBOW"] = 33,
	["BONE_LEFTWRIST"] = 34,
	["BONE_LEFTHAND"] = 35,
	["BONE_LEFTTHUMB"] = 36,
	["BONE_LEFTHIP"] = 41,
	["BONE_LEFTKNEE"] = 42,
	["BONE_LEFTANKLE"] = 43,
	["BONE_LEFTFOOT"] = 44,
	["BONE_RIGHTHIP"] = 51,
	["BONE_RIGHTKNEE"] = 52,
	["BONE_RIGHTANKLE"] = 53,
	["BONE_RIGHTFOOT"] = 54,
	["BONE_BELLY"] = 201,
	["BONE_RIGHTBREAST"] = 301,
	["BONE_LEFTBREAST"] = 302,

	-- Extra
	["BONE_SPINE1BACKPACK"] = 3,
	["BONE_HANDWEAPON"] = 24,
}

function GetBoneId(identifier)
	if type(identifier) == "number" then
		return VALID_BONE_IDS[identifier] and identifier or false
	elseif type(identifier) == "string" then
		return VALID_BONE_NAMES_BY_ID[identifier]
	else
		return false
	end
end