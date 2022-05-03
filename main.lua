GreedSpecialRooms = RegisterMod("Greed Mode Special Rooms", 1)
local mod = GreedSpecialRooms
local game = Game()
local rng = RNG()

mod.savedrooms={}

function mod:DoSacrifice()
	local level = game:GetLevel()
	Isaac.ExecuteCommand("goto s.sacrifice.0")
	local gotor = level:GetRoomByIdx(-3,0)
	if gotor.Data then
		mod.savedrooms["sacrifice"] = gotor.Data
	end
	Isaac.ExecuteCommand("goto 6 7 0")

	local room = level:GetRoomByIdx(83,0)
	room.Data = mod.savedrooms["sacrifice"]
end

function mod:DoDice()
	local level = game:GetLevel()
	Isaac.ExecuteCommand("goto s.dice.0")
	local gotor = level:GetRoomByIdx(-3,0)
	if gotor.Data then
		mod.savedrooms["dice"] = gotor.Data
	end
	Isaac.ExecuteCommand("goto 6 7 0")

	local room = level:GetRoomByIdx(83,0)
	room.Data = mod.savedrooms["dice"]
end

function mod:DoLibrary()
	local level = game:GetLevel()
	Isaac.ExecuteCommand("goto s.library.0")
	local gotor = level:GetRoomByIdx(-3,0)
	if gotor.Data then
		mod.savedrooms["library"] = gotor.Data
	end
	Isaac.ExecuteCommand("goto 6 7 0")

	local room = level:GetRoomByIdx(83,0)
	room.Data = mod.savedrooms["library"]
end

function mod:DoIsaacs()
	local level = game:GetLevel()
	Isaac.ExecuteCommand("goto s.isaacs.0")
	local gotor = level:GetRoomByIdx(-3,0)
	if gotor.Data then
		mod.savedrooms["isaacs"] = gotor.Data
	end
	Isaac.ExecuteCommand("goto 6 7 0")

	local room = level:GetRoomByIdx(83,0)
	room.Data = mod.savedrooms["isaacs"]
end

function mod:DoBarren()
	local level = game:GetLevel()
	Isaac.ExecuteCommand("goto s.barren.0")
	local gotor = level:GetRoomByIdx(-3,0)
	if gotor.Data then
		mod.savedrooms["barren"] = gotor.Data
	end
	Isaac.ExecuteCommand("goto 6 7 0")

	local room = level:GetRoomByIdx(83,0)
	room.Data = mod.savedrooms["barren"]
end

function mod:DoPlanetarium()
	local level = game:GetLevel()
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
	Isaac.ExecuteCommand("goto 6 7 0")

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
	local player = Isaac.GetPlayer(0)
	local targetRoom = nil
	rng:SetSeed(game:GetSeeds():GetStageSeed(level:GetStage()),0)
	
	if rng:RandomInt(7) == 0 or (player:HasFullHearts() and rng:RandomInt(4) == 0) then
		if rng:RandomInt(50) == 0 or (player:GetNumKeys() >= 2 and rng:RandomInt(5) == 0)then
			mod:DoDice()
			targetRoom = RoomType.ROOM_DICE
		else
			mod:DoSacrifice()
			targetRoom = RoomType.ROOM_SACRIFICE
		end
	elseif rng:RandomInt(20) == 0 then
		mod:DoLibrary()
		targetRoom = RoomType.ROOM_LIBRARY
	elseif rng:RandomInt(50) == 0 or (((player:GetHearts() < 4 and player:GetSoulHearts() == 0) or (player:GetHearts() == 0 and player:GetSoulHearts() < 4)) and rng:RandomInt(5) == 0) then
		if rng:RandomInt(2) == 0 then
			mod:DoIsaacs()
			targetRoom = RoomType.ROOM_ISAACS
		else
			mod:DoBarren()
			targetRoom = RoomType.ROOM_BARREN
		end
	end
	if targetRoom then
		game:GetRoom():RemoveDoor(DoorSlot.LEFT0)
	end
	
	if rng:RandomFloat() < level:GetPlanetariumChance() then
		mod:DoPlanetarium()
	end
end

function mod:Level()
	local level = game:GetLevel()
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