Log("SleepingBag : Loading SleepingBag Action !")

local SecuredArea = SBConf.BaseDistance

local ValidPlacement = {}

if CryAction.IsDedicatedServer() then
    RegisterCallback(
        Item,
        "OnActionPerformed",
        function(itemId, playerId, action)

            if action == "Set Respawn Point" then

				local player = System.GetEntity(playerId)
				local playerName = player:GetName()
				local steamId = player.player:GetSteam64Id()
				local playerdata = PlayerDataManager(player)

				Log("SleepingBag : Player %s [%s] wants to set a custom respawn point !", tostring(playerName), tostring(steamId))
				Log("SleepingBag : Checking if an enemy base is around...")

				local bases = BaseBuildingSystem.GetPlotSigns();

				for i,b in pairs(bases) do

					local playerPos = player:GetWorldPos()
					local basePos = b:GetWorldPos()

					if (playerPos.x - basePos.x) > SecuredArea or (playerPos.x - basePos.x) < -SecuredArea then

						playerdata:Set("SleepingBag", playerPos)
						playerdata:Sync()

						ValidPlacement[playerId] = true

					elseif (playerPos.y - basePos.y) > SecuredArea or (playerPos.y - basePos.y) < -SecuredArea then

						playerdata:Set("SleepingBag", playerPos)
						playerdata:Sync()

						ValidPlacement[playerId] = true

					else

						g_gameRules.game:SendTextMessage(4, player, "You can not set a respawn point near bases, please move away a little...")
						g_gameRules.game:SendTextMessage(0, player, "Can't do that here")
						Log("SleepingBag : Player was inside base protection area, saving position aborted !")

					end -- end loop

				--[[	if bases[1] == nil then    					-- TODO : rework condition // current : needs at least 1 base in the GetPlotSigns list

						playerdata:Set("SleepingBag", playerPos)
						playerdata:Sync()

						Log("SleepingBag : Registered player respawn position !")
						g_gameRules.game:SendTextMessage(4, player, "Respawn point has been set !")

						local MemorizedPos = playerdata:Get("SleepingBag")
						Log("SleepingBag : Memorized Respawn Position for player %s > %s %s %s ", tostring(playerName), tostring(MemorizedPos.x), tostring(MemorizedPos.y), tostring(MemorizedPos.z))

					end
				]]--

					if ValidPlacement[playerId] then
						g_gameRules.game:SendTextMessage(4, player, "A new respawn point has been set !")
						g_gameRules.game:SendTextMessage(0, player, "Respawn point saved")

						Log("SleepingBag : Registered player respawn position !")

						local MemorizedPos = playerdata:Get("SleepingBag")
						Log("SleepingBag : Memorized Respawn Position for player %s > %s %s %s ", tostring(playerName), tostring(MemorizedPos.x), tostring(MemorizedPos.y), tostring(MemorizedPos.z))

						ValidPlacement[playerId] = false
					end
				end
            end
        end
    )
end