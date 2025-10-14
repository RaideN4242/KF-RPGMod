class DTBullet extends ShotgunBullet;

var() array<Sound> ExplodeSounds;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Velocity = Speed * Vector(Rotation); // starts off slower so combo can be done closer

	SetTimer(0.4, false);
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
	if ( Role == ROLE_Authority )
	{
		HurtRadius(Damage*0.75, DamageRadius, MyDamageType, 0.0, HitLocation );
		HurtRadius(Damage*0.25, DamageRadius*2.0, MyDamageType, MomentumTransfer, HitLocation );
		
		//does full damage within DamageRadius (dealt in two chunks), but less damage to things outside of DamageRadius but within
		//DamageRadius*2.0
	}

	//why would it matter if instigator exists or not for spawning an fx???
		PlaySound(ExplodeSounds[rand(ExplodeSounds.length)],,1.0);
		
		if ( EffectIsRelevant(Location,false) )
		{
			Spawn(class'DTBulletEmitter',self,,Location);
		}	

	Destroy();
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( Pawn(Owner).Controller );
			if ( Victims == LastTouched )
				LastTouched = None;
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Pawn(Owner),
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Pawn(Owner).Controller, DamageType, Momentum, HitLocation);

		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;
		damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(Pawn(Owner).Controller);
		Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
			(damageScale * Momentum * dir),
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Pawn(Owner).Controller, DamageType, Momentum, HitLocation);
	}

	bHurtEntry = false;
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if ( Other != Instigator && !Other.IsA('PhysicsVolume') && (Other.IsA('Pawn') || Other.IsA('ExtendedZCollision')) )
	{
		Other.Velocity.X = Self.Velocity.X * 0.10;
		Other.Velocity.Y = Self.Velocity.Y * 0.10;
		Other.Velocity.Z = Self.Velocity.Z * 0.10;
		Other.Acceleration = vect(0,0,0); //0,0,0
		
		Explode(Other.Location,Other.Location);
	}
}

defaultproperties
{
     ExplodeSounds(0)=Sound'KF_GrenadeSnd.NadeBase.Nade_Explode1'
     Speed=4000.000000
     MaxSpeed=5000.000000
     Damage=7.000000
     DamageRadius=10.000000
     MomentumTransfer=30000.000000
     MyDamageType=Class'IDRPGMod.ID_Weapon_Base_Turret_DamageType'
}
