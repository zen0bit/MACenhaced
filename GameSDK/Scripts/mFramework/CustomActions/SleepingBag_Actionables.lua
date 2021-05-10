Log("SleepingBag : Initializing Actions...")


local SleepingBag_action = {
    ["Set Respawn Point"] = function(self, player, action)
        return
    end
}

local SleepingBagCustomized, SleepingBag_reason = mCustomizeActions("sleeping_bag", SleepingBag_action, true)

if SleepingBagCustomized then
    Script.ReloadScript("Scripts/mFramework/CustomActions/SleepingBag_ActionCallbacks/SleepingBagScript.lua")
else
    Log("SleepingBag : CustomAction Failed > %s", SleepingBag_reason)
end

-- ────────────────────────────────────────────────────────────────────────────────
--
