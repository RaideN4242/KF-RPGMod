class WTFEquipAFS12ForceBullet extends ShotgunBullet;

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if (Other == None)
		return;

	if (KFMonster(Other) == None)
		return;

	if ( Other.Physics == PHYS_Walking )
		Other.SetPhysics(PHYS_Falling);

	Other.Velocity.X = Self.Velocity.X * 0.05;
	Other.Velocity.Y = Self.Velocity.Y * 0.05;
	Other.Velocity.Z = Self.Velocity.Z * 0.05;

	Other.Acceleration = vect(0,0,0); //0,0,0

	Super.ProcessTouch(Other,HitLocation);
}

defaultproperties
{
     PenDamageReduction=0.750000
     HeadShotDamageMult=2.500000
     Damage=222.000000
     DamageRadius=1.000000
     MomentumTransfer=70000.000000
     MyDamageType=Class'IDRPGMod.ID_Weapon_Base_AA12AS_DamageType'
     LifeSpan=5.000000
     DrawScale=5.000000
}
