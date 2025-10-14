class LureNadeLure extends FlameTendril;

var() FireSprayFuelFlame FF;
var() bool bHasLanded;

var() KFMonster StuckTo;
var() float SlowedGroundSpeed;
var() float DefaultGroundSpeed;
var() float ReduceSpeedTo;
var() bool bSlowPoison;

simulated function PostBeginPlay();

singular simulated function HitWall(Vector HitNormal, Actor Wall)
{
	Destroy();
}

simulated function Landed(Vector HitNormal)
{
	Destroy(); 
}

simulated function Explode(Vector HitLocation, Vector HitNormal)
{
	/*if(KFHumanPawn(Instigator) != none)
	{
		if(EffectIsRelevant(Location, false))
		{
			
		}
	}*/	
	Destroy();
}


simulated function ProcessTouch(Actor Other, Vector HitLocation);

simulated function Destroyed();

function Timer()
{
	if(StuckTo != none)
	{
		if(StuckTo.Health <= 0)
		{
			Destroy();
		}
		
		if(Role == ROLE_Authority)
		{
			StuckTo.TakeDamage(int(Damage), Instigator, StuckTo.Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			
			if(bSlowPoison)
			{
				if(StuckTo.OriginalGroundSpeed > SlowedGroundSpeed)
				{
					if(!StuckTo.IsA('ZombieBoss'))
					{
						StuckTo.OriginalGroundSpeed = SlowedGroundSpeed;
					}
					else
					{
						StuckTo.OriginalGroundSpeed = DefaultGroundSpeed * FMin(ReduceSpeedTo * 2.0, 1.0);
						//Log("LethalInjectionProj: Timer(): I'm stuck to a Patriarch-type monster!");
						//Log((("LethalInjectionProj: Timer(): OriginalGroundSpeed reduced to " $ string(StuckTo.OriginalGroundSpeed)) $ " instead of ") $ string(SlowedGroundSpeed));
					}
				}
				
				if(LifeSpan <= 1.0)
				{
					StuckTo.OriginalGroundSpeed = DefaultGroundSpeed;
				}
			}
		}
	}  
}

function SetSpeeds()
{
	local float MovementSpeedDifficultyScale;

	if(Level.Game.GameDifficulty < 2.0)
	{
		MovementSpeedDifficultyScale = 0.950;
	}
	else
	{
		if(Level.Game.GameDifficulty < 4.0)
		{
			MovementSpeedDifficultyScale = 1.0;
		}
		else
		{
			if(Level.Game.GameDifficulty < 7.0)
			{
				MovementSpeedDifficultyScale = 1.150;
			}
			else
			{
				MovementSpeedDifficultyScale = 1.30;
			}
		}
	}
	DefaultGroundSpeed = StuckTo.default.GroundSpeed * MovementSpeedDifficultyScale;
	SlowedGroundSpeed = DefaultGroundSpeed * ReduceSpeedTo;
}

simulated function Stick(Actor HitActor, Vector HitLocation)
{
	local name NearestBone;
	local float dist;

	StuckTo = KFMonster(HitActor);
	SetSpeeds();
	SetPhysics(Phys_None);
	NearestBone = GetClosestBone(HitLocation, HitLocation, dist, 'CHR_Spine2', 15.0);
	HitActor.AttachToBone(self, NearestBone);
	SetTimer(0.50, true);
}

final simulated function ProcessGravity(float Delta)
{
	local KFMonster A;
	local Vector D;
	local float dist;

	foreach VisibleCollidingActors(class'KFMonster', A, 500.0)
	{
		if((((A.Class == Class) || A.bStatic) || !A.bMovable) || A == none)
		{
			continue;			
		}
		
		if((A.Physics == PHYS_Walking) || A.Physics == PHYS_None)
		{
			A.SetPhysics(PHYS_Falling);
		}
		
		D = Location - A.Location;
		dist = VSize(D);
		
		if(A.Physics == PHYS_Karma || A.Physics == PHYS_KarmaRagdoll)
		{
			A.KAddImpulse(Normal(D) * (((float(360) - dist) * Delta) * 0.50), vect(0.0, 0.0, 0.0));
			continue;
		}
		
		if(dist > float(500))
		{
			A.Velocity += ((Normal(D) * (float(360) - dist)) * Delta);
			continue;
		}
		A.Velocity = Normal(D) * 150.0;		
	}
}

simulated function Tick(float Delta)
{
	ProcessGravity(Delta);
}

defaultproperties
{
     ReduceSpeedTo=0.300000
     bSlowPoison=True
     Speed=1.000000
     MaxSpeed=1.000000
     Damage=500.000000
     DamageRadius=1.000000
     MyDamageType=Class'IDRPGMod.DamTypeLethalSyringe'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'KF_pickups2_Trip.Supers.MP7_Dart'
     LifeSpan=15.000000
     DrawScale=0.010000
}
