class ID_Skill_Weapon_MP7M extends ID_RPG_Base_Skill_Weapon;

static function float GetDamageMulti(ID_RPG_Base_HumanPawn Player, class<DamageType> DmgType)
{
	if (ClassIsChildOf(Player.Weapon.class, default.Weapon) || MP7Dual(Player.Weapon)!=None)
		return GetDamageMultiInternal(GetSkillLevel(Player));
	return 0;
}

defaultproperties
{
     Weapon=Class'IDRPGMod.ID_Weapon_Base_MP7M'
     SkillIndex=33
     Icon=Texture'KillingFloor2HUD.WeaponSelect.MP7m'
}
