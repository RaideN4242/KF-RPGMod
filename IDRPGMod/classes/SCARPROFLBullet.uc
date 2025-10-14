class SCARPROFLBullet extends ShotgunBullet;

simulated function PostBeginPlay()
{
	Super(Projectile).PostBeginPlay();

	Velocity = Speed * Vector(Rotation); // starts off slower so combo can be done closer

	SetTimer(0.4, false);	
}

simulated function Destroyed()
{
	super(projectile).Destroyed();
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	if ( Role == ROLE_Authority )
	{
		if ( !Wall.bStatic && !Wall.bWorldGeometry )
		{
			if ( Instigator == None || Instigator.Controller == None )
				Wall.SetDelayedDamageInstigatorController( InstigatorController );
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			if (DamageRadius > 0 && Vehicle(Wall) != None && Vehicle(Wall).Health > 0)
				Vehicle(Wall).DriverRadiusDamage(Damage, DamageRadius, InstigatorController, MyDamageType, MomentumTransfer, Location);
			HurtWall = Wall;
		}
		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);

	if (ImpactEffect != None && (Level.NetMode != NM_DedicatedServer))
	{
			Spawn(ImpactEffect,,, Location, rotator(-HitNormal));
	}

	HurtWall = None;	

	Destroy();
}

defaultproperties
{
     MaxPenetrations=0
     Speed=1500.000000
     MaxSpeed=2000.000000
     Damage=1800.000000
     MomentumTransfer=25000.000000
     MyDamageType=Class'IDRPGMod.DamTypeSCARPROFAssaultRifle'
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'DZResPack.LParticeMesh'
}
