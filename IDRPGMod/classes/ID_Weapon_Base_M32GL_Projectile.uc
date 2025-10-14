class ID_Weapon_Base_M32GL_Projectile extends M79GrenadeProjectile;

simulated function PostBeginPlay()
{
//	local rotator SmokeRotation;

	BCInverse = 1 / BallisticCoefficient;

	OrigLoc = Location;

	if( !bDud )
	{
		Dir = vector(Rotation);
		Velocity = speed * Dir;
	}

	if (PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity=0.6*Velocity;
	}
	super(Projectile).PostBeginPlay();
}

defaultproperties
{
     ExplosionSound=SoundGroup'KF_GrenadeSnd.Nade_Explode_1'
     ArmDistSquared=40000.000000
     MomentumTransfer=5000.000000
     MyDamageType=Class'IDRPGMod.ID_Weapon_Base_M32GL_DamageType'
}
