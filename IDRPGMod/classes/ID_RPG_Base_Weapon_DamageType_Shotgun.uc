class ID_RPG_Base_Weapon_DamageType_Shotgun extends ID_RPG_Base_Weapon_DamageType_Projectile
	abstract;

defaultproperties
{
     IsShotgun=True
     WeaponClass=Class'KFMod.Shotgun'
     DeathString="%k killed %o (Shotgun)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     FlashFog=(X=600.000000)
}
