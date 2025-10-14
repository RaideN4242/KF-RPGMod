class ID_Skill_Weapon_Turret extends ID_RPG_Base_Skill_Weapon;

static function float GetDamageMulti(ID_RPG_Base_HumanPawn Player, class<DamageType> DmgType)
{
	if(bDamageTypeIsCorrect(DmgType))
		return GetDamageMultiInternal(GetSkillLevel(Player));
	return Super.GetDamageMulti(Player,DmgType);
}

static function bool bDamageTypeIsCorrect(class<DamageType> DmgType)
{
	local array< class<DamageType> > DmgTypes;
	local int i;

	DmgTypes[DmgTypes.Length]=class'ID_Weapon_Base_Turret_DamageType';
//	DmgTypes[DmgTypes.Length]=class'SentryGunWYDTAI';

	for(i=0;i<DmgTypes.Length;i++)
	{
		if(ClassIsChildOf(DmgType,DmgTypes[i]))
		{
			return true;
		}
	}

	return false;
}

defaultproperties
{
     Weapon=Class'IDRPGMod.ID_Weapon_Base_Turret'
     SkillIndex=27
     MaxLevel=65000000
     Icon=Texture'WPCAlienWeap_T.HUD.SentryGun_Selected'
}
