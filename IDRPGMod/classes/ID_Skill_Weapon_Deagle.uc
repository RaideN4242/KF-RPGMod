class ID_Skill_Weapon_Deagle extends ID_RPG_Base_Skill_Weapon;

static function float GetDamageMulti(ID_RPG_Base_HumanPawn Player, class<DamageType> DmgType)
{
	if (ClassIsChildOf(Player.Weapon.class, default.Weapon) || Player.Weapon.Class==class'DeaglePro')
		return GetDamageMultiInternal(GetSkillLevel(Player));
	return 0;
}

defaultproperties
{
     Weapon=Class'IDRPGMod.ID_Weapon_Base_Deagle'
     SkillIndex=21
     Icon=Texture'KillingFloorHUD.WeaponSelect.handcannon'
}
