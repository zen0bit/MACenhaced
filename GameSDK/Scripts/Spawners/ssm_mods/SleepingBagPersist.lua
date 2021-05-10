

	Log("SleepingBag : SleepingBagPersist loading ...")

	local SBStructure = { class = "sleeping_bag" }

	local TargetTent = FindInTable(StructureSpawnerManager.StructureCategories, "category", "tent")
	table.insert(TargetTent.classes, SBStructure)
	--dump(TargetTent)
	Log("SleepingBag : Sleeping Bag added to Persistence !")