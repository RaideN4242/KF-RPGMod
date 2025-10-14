class ID_Skill_Weapon_Moss12S extends ID_RPG_Base_Skill_Weapon;

static function float GetDamageMulti(ID_RPG_Base_HumanPawn Player, class<DamageType> DmgType)
{
	if (ClassIsChildOf(Player.Weapon.class, default.Weapon) || Player.Weapon.Class==class'SPAS12')
		return GetDamageMultiInternal(GetSkillLevel(Player));
	return 0;
}

defaultproperties
{
     Weapon=Class'IDRPGMod.ID_Weapon_Base_Moss12S'
     SkillIndex=34
     Icon=Texture'WPCAlienWeap_T.HUD.HUD_Moss12_selected'
}
