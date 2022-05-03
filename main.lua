GreedSpecialRooms = RegisterMod("Greed Mode Special Rooms", 1)
local mod = GreedSpecialRooms
local game = Game()
local rng = RNG()

mod.savedrooms={}

function mod:DoLibrary()
	local room = level:GetRoomByIdx(83,0)
end

function mod:DoPlanetarium()
	local ran = rng:RandomInt(11)
	local id
	if ran < 4 then
		id = 0
	elseif ran < 8 then
		id = 1
	elseif ran < 10 then
		id = 2
	elseif ran == 10 then
		id = 3
	end
	
	Isaac.ExecuteCommand("goto s.planetarium."..id)
	local gotor = level:GetRoomByIdx(-3,0)
	if gotor.Data then
		mod.savedrooms["planetarium"] = gotor.Data
	end
	Isaac.ExecuteCommand("goto 6 6 0")

	local levelStage = level:GetStage()
	local stageType = level:GetStageType()
	level:SetStage(7, 0)		
	if level:MakeRedRoomDoor(71, DoorSlot.RIGHT0) then
		local newRoom = level:GetRoomByIdx(72,0)
		newRoom.Data = mod.savedrooms["planetarium"]
		newRoom.DisplayFlags = 5
		newRoom.Flags = 0
		print("planetarium spawned")
	end
	level:SetStage(levelStage, stageType)
end

function mod:Init()
	local level = game:GetLevel()
	rng:SetSeed(game:GetSeeds():GetStageSeed(level:GetStage()),0)
	
	if rng:RandomInt(20) == 0 then
		--mod:DoLibrary()
	end
	
	if rng:RandomFloat() < level:GetPlanetariumChance() then
		mod:DoPlanetarium()
	end
end

function mod:Level()
	if game:IsGreedMode() then
		mod:Init()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.Level)

-----mod compatibility-----
function mod:PlanetariumChanceCompat()
	if PlanetariumChance then
		if game:IsGreedMode() then
			PlanetariumChance.storage.canPlanetariumsSpawn = 1
			PlanetariumChance:updatePlanetariumChance()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.PlanetariumChanceCompat)