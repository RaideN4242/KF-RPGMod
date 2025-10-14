class ID_Util_Base_RadialShotSystem extends ID_RPG_Base_Util_WithTimer;

var int Damage;
var int Radius;
var int MaxTargets;

replication
{
	reliable if( Role == ROLE_Authority )
		Hit;
}

simulated function Hit(vector PlayerLocation, vector MonsterLocation)
{
	local KFNewTracer Tracer;
	local vector SpawnDir;
	local vector SpawnVel;
	local float Dist;
	//log("xxx");
	Tracer = Spawn(Class'KFNewTracer');
	if( Tracer!=None )
	{
		Tracer.SetLocation(PlayerLocation);

		Dist = VSize(MonsterLocation - PlayerLocation) ;
		SpawnDir = Normal(MonsterLocation - PlayerLocation);
		SpawnVel = SpawnDir * 10000;
		Tracer.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
		Tracer.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
		Tracer.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
		Tracer.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
		Tracer.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
		Tracer.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;

		Tracer.Emitters[0].LifetimeRange.Min = 0.4;
		Tracer.Emitters[0].LifetimeRange.Max = Tracer.Emitters[0].LifetimeRange.Min;

		Tracer.SpawnParticle(1);
	}
}

simulated function Timer()
{
	local ID_RPG_Base_Monster Monster;
	local int FireCount;
	foreach Player.RadiusActors(class'ID_RPG_Base_Monster', Monster, Radius)
	{
		Monster.TakeDamage(Damage, Player, vect(0,0,0), vect(0,0,0), Class'ID_Util_Base_RadialShotSystem_DamageType');
		Hit(Player.Location, Monster.Location);	
		FireCount++;
		if (FireCount >= MaxTargets)
			return;
	}
}

static function  string GetItemInfo()
{
	return "Damages emenies in radius of" @ default.Radius / 50 @ "meters by" @ default.Damage @ "HP every" @ default.Interval @ "seconds." $ 
				"|Max targets:" @ default.MaxTargets;
}

defaultproperties
{
     Damage=100
     Radius=300
     MaxTargets=3
     Interval=3.000000
     PickupClass=Class'IDRPGMod.ID_Util_Base_RadialShotSystem_Pickup'
     ItemName="Radial Shot defence system"
}
