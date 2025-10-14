class ID_Skill_Weapon_M32GL extends ID_RPG_Base_Skill_Weapon;

static function float GetDamageMulti(ID_RPG_Base_HumanPawn Player, class<DamageType> DmgType)
{
	if (ClassIsChildOf(Player.Weapon.class, default.Weapon) || M32Pro(Player.Weapon)!=None)
		return GetDamageMultiInternal(GetSkillLevel(Player));
	return 0;
}

defaultproperties
{
     Weapon=Class'IDRPGMod.ID_Weapon_Base_M32GL'
     SkillIndex=25
     Icon=Texture'KillingFloor2HUD.WeaponSelect.M32'
}
