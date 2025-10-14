class ID_GUI_List_PerkProgress extends KFPerkProgressList;

function PerkChanged(KFSteamStatsAndAchievements KFStatsAndAchievements, int NewPerkIndex)
{
	ItemCount = 0;
	SetIndex(0);

	RequirementString.Remove(0, RequirementString.Length);
	RequirementProgressString.Remove(0, RequirementProgressString.Length);
	RequirementProgress.Remove(0, RequirementProgress.Length);

	if ( MyScrollBar != none )
		MyScrollBar.AlignThumb();
}

defaultproperties
{
}
