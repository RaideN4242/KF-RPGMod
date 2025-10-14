class ID_Skill_Weapon_M14EBR extends ID_RPG_Base_Skill_Weapon;

static function float GetDamageMulti(ID_RPG_Base_HumanPawn Player, class<DamageType> DmgType)
{
	if (ClassIsChildOf(Player.Weapon.class, default.Weapon) || M14EBRPro(Player.Weapon)!=None)
		return GetDamageMultiInternal(GetSkillLevel(Player));
	return 0;
}

defaultproperties
{
     Weapon=Class'IDRPGMod.ID_Weapon_Base_M14EBR'
     SkillIndex=24
     Icon=Texture'KillingFloor2HUD.WeaponSelect.M14'
}
