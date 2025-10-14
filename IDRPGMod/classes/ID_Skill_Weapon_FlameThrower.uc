class ID_Skill_Weapon_FlameThrower extends ID_RPG_Base_Skill_Weapon;

static function float GetDamageMulti(ID_RPG_Base_HumanPawn Player, class<DamageType> DmgType)
{
	if (ClassIsChildOf(Player.Weapon.class, default.Weapon) || Petrolboomer(Player.Weapon)!=None)
		return GetDamageMultiInternal(GetSkillLevel(Player));
	return 0;
}

defaultproperties
{
     Weapon=Class'IDRPGMod.ID_Weapon_Base_FlameThrower'
     SkillIndex=22
     Icon=Texture'KillingFloorHUD.WeaponSelect.FlameThrower'
}
