class ID_Skill_Weapon_Crossbow extends ID_RPG_Base_Skill_Weapon;

static function float GetDamageMulti(ID_RPG_Base_HumanPawn Player, class<DamageType> DmgType)
{
	if (ClassIsChildOf(Player.Weapon.class, default.Weapon) || Player.Weapon.Class==class'NinjaCrossbowPro')
		return GetDamageMultiInternal(GetSkillLevel(Player));
	return 0;
}

defaultproperties
{
     Weapon=Class'IDRPGMod.ID_Weapon_Base_Crossbow'
     SkillIndex=20
     Icon=Texture'KillingFloorHUD.WeaponSelect.Crossbow'
}
