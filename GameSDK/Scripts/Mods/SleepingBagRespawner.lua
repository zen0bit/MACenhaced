
--
----------------------------------------------------------------------------------------------------------------------
-- 									    SLEEPING BAG - Placeable Respawner
----------------------------------------------------------------------------------------------------------------------
--
--      	 SLEEPING BAG lets players obtain a placeable item, from which they can define a Respawn point.
--       This point will be saved and will be persistent throughout server restarts using mFramework DB feature.
--	       Players will be automatically moved to Saved Pos on death, unless they release it via ChatCommand.
--		    The item have to be placed on the ground, and there is a global position check around all bases
--				to prevent players from saving their respawn point too close to ennemy territories.
--
--                      For more information on the mod, please check the Workshop page :
--                      https://steamcommunity.com/sharedfiles/filedetails/?id=2434285686
--
--     If you need any help with this script : please contact @PitiViers in MisModding Discord : discord.gg/ttdzgzp
--
--                                            Have fun !   -PitiViers.
--
---------------------------------------------------------------------------------------------------------------------
--
--  UPDATES --
--
-- #1. RELEASE
-- #2. Changed the method used to revive dead players to maximise compatibility (RegisterCallbackReturnAware) + Various typos fix
--
--
-- ─── CONFIG FUNCTIONS ─────────────────────────────────────────────────────────────────────────────────────────────
--
-- (!) NOTE --
-- (!) The configuration is handled by a lua file created at game server root the first time the mod is launched on a server.
-- (!) Edit the configuration to customize the mod @ SleepingBag_Config.lua
-- (!) DO NOT EDIT THIS FILE just to change the configuration.
--

-- Default Config

SBConf = {
	AddToTrader = 1,
	AddToSpawns = 1,
	BaseDistance = 100,
	ClearCommand = "!clear"
}

local configuration = [[

----------------------------------------------------------------------------------------------------------------------
-- 									    SLEEPING BAG - Placeable Respawner
----------------------------------------------------------------------------------------------------------------------
--      	 SLEEPING BAG lets players obtain a placeable item, from which they can define a Respawn point.
--	       Players will be automatically moved to Saved Pos on death, unless they release it with a ChatCommand.
--		    The item have to be placed on the ground, and there is a global position check around all bases
--				to prevent players from saving their respawn point too close to ennemy territories.
--
-- 			If you need any assistance, please contact PitiViers on MisModding Discord : discord.gg/ttdzgzp
--
-- 													Enjoy !
----------------------------------------------------------------------------------------------------------------------


local SleepingBagConfiguration = {

	AddToTrader = 1,			--- Allow Sleeping Bag item to be purchase at Food, Cloth and Epic Traders // Enable (1) or disable (0)

	AddToSpawns = 1,			--- Allow Sleeping Bag item to spawn in various places around the world // Enable (1) or disable (0)

	BaseDistance = 100,			--- Minimum distance of any base from where a player can set his Respawn Position

	ClearCommand = "!clear"		--- Customizable Chat Command to forget last Saved Position (Keep the quotes and the exclamation mark)

}

-- NOTE : if you need to spawn the item, or if you want to better integrate it on your server,
-- 		  like making the Sleeping Bag craftable, the targeted ID is <sleeping_bag_rolled>.

-- PLANNED : Disable respawn when Sleeping Bag is removed/destroyed,
--			 Give the option to easily customize vendor cost (when officialy supported)
    
    return SleepingBagConfiguration;   -- Do not touch this !
]];

--- CONFIG FILE MANAGEMENT ---------------------------------------------------------------------------------------


local function WriteConfig(filename)
    os.execute("mkdir Mods_Config")
    file = io.open ('Mods_Config/SleepingBag_Config.lua', "w");
    file:write(configuration);
    file:close();
end

local function SetConfig(filename)
    local file = io.open (filename);
    if file == nil then
        WriteConfig(filename);
        Log('SleepingBag : Configuration file has been created !')
        return;
    end
    file:close();
    package.path = "./Mods_Config/"..filename..";"..package.path;
    local SleepingBagConfiguration = require(filename);
    for a, b in pairs(SleepingBagConfiguration) do
        SBConf[a] = b;
        Log('SleepingBag : Applying configuration...')
    end
    Log('SleepingBag : Configuration has been successfuly applied from SleepingBag_Config.lua !')
end

--- MAIN RESPAWNER SCRIPT -----------------------------------------------------------------------------------------------

Log("SleepingBag : Loading SleepingBagRespawner")

RegisterCallbackReturnAware(
    Miscreated,
    'InitPlayer',
	function(self, ret, playerId)
		Log("SleepingBag: Trying to move a dead player to a saved position...")

		local player = System.GetEntity(playerId)
		local playerName = player:GetName()
		local steamId = player.player:GetSteam64Id()
		local playerdata = PlayerDataManager(player)
		local MemorizedPos = playerdata:Get("SleepingBag")
			Log("SleepingBag : Player is %s [%s]", tostring(playerName), tostring(steamId))
			Log("SleepingBag : Memorized Respawn Position for player %s > %s %s %s ", tostring(playerName), tostring(MemorizedPos.x), tostring(MemorizedPos.y), tostring(MemorizedPos.z))

		if MemorizedPos == nil then
			Log("SleepingBag : Player %s doesn't have any saved respawn point", tostring(playerName))
		else
		player:SetWorldPos(MemorizedPos)
			Log("SleepingBag : Player %s has been moved to his Respawn Position", tostring(playerName))
		end
		return ret;
	end,
	nil
);


--- CHAT COMMAND ----------------------------------------------------------------------------

local ClearCMD = SBConf.ClearCommand

ChatCommands[ClearCMD] = function(playerId)

	Log("SleepingBag : Clear Respawn CC requested")

	if CryAction.IsDedicatedServer() then

		Log("SleepingBag : We're on server side !")

		local player = System.GetEntity(playerId)
		local playerdata = PlayerDataManager(player)

		playerdata:Set("SleepingBag", nil)
		playerdata:Sync()

		Log("SleepingBag : Respawn point has been cleared")
		g_gameRules.game:SendTextMessage(4, player, "You can't remember where you've placed your sleeping bag anymore...")
		g_gameRules.game:SendTextMessage(0, player, "Respawn point released")

	else
		Log("SleepingBag : We're still on client side, aborting chat command")
	end
end

----- SPAWNERS ----------------------------------------------------------------------------

local SBspawnTrader = {
	class = "sleeping_bag_rolled",
	percent = 100,
}

local SBspawnCamping = {
	class = "sleeping_bag_rolled",
	percent = 5,
}

local SBspawnTool = {
	class = "sleeping_bag_rolled",
	percent = 2,
}

local SBspawnHouse = {
	class = "sleeping_bag_rolled",
	percent = 5,
}

local SBspawnHospital = {
	class = "sleeping_bag_rolled",
	percent = 8,
}

function BagSpawnerManager()
	Log("SleepingBag : Deploying Spawner Manager...")

	if SBConf.AddToTrader == 1 then
		Log("SleepingBag : Applying Sleeping Bag to Traders...")
		local categoryToAdjust = FindInTable(ItemSpawnerManager.itemCategories, "category", "FoodVendorInventory")
		local categoryToAdjust2 = FindInTable(ItemSpawnerManager.itemCategories, "category", "ShadyVendorInventory")
		local categoryToAdjust3 = FindInTable(ItemSpawnerManager.itemCategories, "category", "VendorClothingCivilian")
		local categoryToAdjust4 = FindInTable(ItemSpawnerManager.itemCategories, "category", "VendorClothingMilitary")
		table.insert(categoryToAdjust.group, SBspawnTrader)
		table.insert(categoryToAdjust2.group, SBspawnTrader)
		table.insert(categoryToAdjust3.group, SBspawnTrader)
		table.insert(categoryToAdjust4.group, SBspawnTrader)
		Log("SleepingBag : Sleeping Bag to Traders applied !")
	end

	if SBConf.AddToSpawns == 1 then
		Log("SleepingBag : Applying Sleeping Bag to World Spawns...")
		local CampAdjustment = FindInTable(ItemSpawnerManager.itemCategories, "category", "RandomCampingBPart")
		local ToolAdjustment = FindInTable(ItemSpawnerManager.itemCategories, "category", "RandomCrafting")
		local HouseAdjustment = FindInTable(ItemSpawnerManager.itemCategories, "category", "RandomLivingAreaContent")
		local HospitalAdjustment = FindInTable(ItemSpawnerManager.itemCategories, "category", "RandomHospitalContentBig")

		local CampToAdjust = FindInTable(CampAdjustment.classes, "class", "camping_chair")
		local ToolToAdjust = FindInTable(ToolAdjustment.classes, "class", "PropaneHeaterTop")
		local HouseToAdjust = FindInTable(HouseAdjustment.classes, "category", "RandomClothes")
		local HospitalToAdjust = FindInTable(HospitalAdjustment.classes, "category", "RandomHospitalContentMedium")

		table.insert(CampAdjustment.classes, SBspawnCamping)
		table.insert(ToolAdjustment.classes, SBspawnTool)
		table.insert(HouseAdjustment.classes, SBspawnHouse)
		table.insert(HospitalAdjustment.classes, SBspawnHospital)

		ToolToAdjust.percent = ToolToAdjust.percent - SBspawnTool.percent
		CampToAdjust.percent = CampToAdjust.percent - SBspawnCamping.percent
		HouseToAdjust.percent = HouseToAdjust.percent - SBspawnHouse.percent
		HospitalToAdjust.percent = HospitalToAdjust.percent - SBspawnHospital.percent

		Log("SleepingBag : Sleeping Bag to World Spawns applied !")

	end
end


--[[ STARTUP DEPLOYMENT PART -------------------------------------------------------------------

local function CustomVendorCost()						-- TODO : Keeping that for later date...
	Log("SleepingBag : Deploying Vendor Cost...")
	local OldCost = ISM.GetItemVendorCost("sleeping_bag_rolled")
	local NewCost = SBConf.SleepingBagCost
		Log("SleepingBag : Previous cost was %s", tostring(OldCost))
		Log("SleepingBag : Cost to apply is %s", tostring(NewCost))
	OldCost = NewCost
		Log("SleepingBag : New cost is now %s amCoins !", tostring(OldCost))
end

]]--

local function SleepingBagStart()
	--CustomVendorCost()
	SetConfig("SleepingBag_Config.lua")
	BagSpawnerManager()
end

RegisterCallback(_G, 'OnInitPreLoaded', nil, function()
	Log("SleepingBag : Deploying SleepingBag Automation...")
	SleepingBagStart()
end)



