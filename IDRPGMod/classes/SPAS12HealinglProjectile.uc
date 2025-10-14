class SPAS12HealinglProjectile extends ROBallisticProjectile;

var() vector ShakeRotMag;
var() vector ShakeRotRate;
var() float  ShakeRotTime;
var() vector ShakeOffsetMag;
var() vector ShakeOffsetRate;
var() float  ShakeOffsetTime;

var() vector RotMag;
var() vector RotRate;
var() float  RotTime;
var() vector OffsetMag;
var() vector OffsetRate;
var() float  OffsetTime;

var PanzerfaustTrail SmokeTrail;
var vector Dir;
var bool bRing,bHitWater,bWaterStart;

var() sound ExplosionSound;

var () int HealBoostAmount;

var	bool bHitHealTarget;
var	bool bHasExploded;
var	vector HealLocation;
var	rotator HealRotation;

var() float StraightFlightTime;
var float TotalFlightTime;
var bool bOutOfPropellant;

var vector OuttaPropLocation;

replication
{
	reliable if(Role == ROLE_Authority)
		HealLocation, HealRotation;
}

simulated function PostNetReceive()
{
	if( bHidden && !bHitHealTarget )
	{
		if( HealLocation != vect(0,0,0) )
		{
			log("PostNetReceive calling HitHealTarget for location of "$HealLocation);
			HitHealTarget(HealLocation,vector(HealRotation));
		}
		else
		{
			log("PostNetReceive calling HitHealTarget for self location of "$HealLocation);
			HitHealTarget(Location,-vector(Rotation));
		}
	}
}

simulated function Tick( float DeltaTime )
{
	SetRotation(Rotator(Normal(Velocity)));

	if( !bOutOfPropellant )
	{
		if ( TotalFlightTime <= StraightFlightTime )
		{
			TotalFlightTime += DeltaTime;
		}
		else
		{
			OuttaPropLocation = Location;
			bOutOfPropellant = true;
		}
	}

	if(  bOutOfPropellant && bTrueBallistics )
	{
		bTrueBallistics = false;
	}
}

simulated function HitHealTarget(vector HitLocation, vector HitNormal)
{
	bHitHealTarget = true;
	bHidden = true;
	SetPhysics(PHYS_None);

	HealLocation = HitLocation;
	HealRotation = rotator(HitNormal);

	if( Role == ROLE_Authority )
	{
	SetTimer(0.1, false);
	NetUpdateTime = Level.TimeSeconds - 1;
	}

	PlaySound(ExplosionSound,,2.0);

	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(Class'KFMod.HealingFX',,, HitLocation, rotator(HitNormal));
	}
}

function Timer()
{
	Destroy();
}

function ShakeView()
{
	local Controller C;
	local PlayerController PC;
	local float Dist, Scale;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		PC = PlayerController(C);
		if ( PC != None && PC.ViewTarget != None )
		{
			Dist = VSize(Location - PC.ViewTarget.Location);
			if ( Dist < DamageRadius * 2.0)
			{
				if (Dist < DamageRadius)
					Scale = 1.0;
				else
					Scale = (DamageRadius*2.0 - Dist) / (DamageRadius);
				C.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
			}
		}
	}
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	super(Projectile).HitWall(HitNormal,Wall);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	bHasExploded = True;

	if( bHitHealTarget )
	{
		return;
	}

	SetPhysics(PHYS_None);

	if(Level.NetMode != NM_DedicatedServer)
	{
		Spawn(class'ROBulletHitEffect',,, Location, rotator(-HitNormal));
	}

	BlowUp(HitLocation);
	Destroy();
}

simulated function PostBeginPlay()
{
	OrigLoc = Location;

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	if (PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity=0.6*Velocity;
	}
	Super.PostBeginPlay();
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	Explode(HitLocation, vect(0,0,0));
}

simulated function Destroyed()
{
	if ( SmokeTrail != None )
	{
		SmokeTrail.HandleOwnerDestroyed();
	}

	if( !bHasExploded && !bHidden )
		Explode(Location,vect(0,0,1));
	if( bHidden && !bHitHealTarget )
	{
		if( HealLocation != vect(0,0,0) )
		{
			HitHealTarget(HealLocation,vector(HealRotation));
		}
		else
		{
			HitHealTarget(Location,-vector(Rotation));
		}
	}

	Super.Destroyed();
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	return;
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local KFPlayerReplicationInfo PRI;
	local int MedicReward;
	local KFHumanPawn Healed;
	local float HealSum,MaxShieldStrength;

	if ( Other == none || Other == Instigator || Other.Base == Instigator )
		return;

	if( Role == ROLE_Authority )
	{
		Healed = KFHumanPawn(Other);

		if( Healed != none )
		{
			HitHealTarget(HitLocation, -vector(Rotation));
		}

		if ( ID_RPG_Base_HumanPawn(Healed) != none )
		{
			MaxShieldStrength=ID_RPG_Base_HumanPawn(Healed).MaxShieldStrength;
		}
		else
		{
			MaxShieldStrength=100;
		}

		if( Instigator != none && Healed != none && Healed.Health > 0 &&
			Healed.ShieldStrength <  MaxShieldStrength )
		{

			MedicReward = HealBoostAmount;

			PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

			if ( ID_RPG_Base_HumanPawn(Instigator) != none )
			{
				MedicReward *= 1 + class'ID_Skill_Welder'.static.GetWeldDamageMulti(ID_RPG_Base_HumanPawn(Instigator))*0.1;
			}

			HealSum = MedicReward;

			if ( (Healed.ShieldStrength + MedicReward) > MaxShieldStrength )
			{
				MedicReward = MaxShieldStrength - Healed.ShieldStrength;
				if ( MedicReward < 0 )
				{
					MedicReward = 0;
				}
			}

			Healed.AddShieldStrength(HealSum);
			
			if ( PRI != None )
			{
				MedicReward = int((FMin(float(MedicReward),MaxShieldStrength)/MaxShieldStrength) * 60);

				PRI.Score += MedicReward;
				PRI.ThreeSecondScore += MedicReward;
				PRI.Team.Score += MedicReward;

				if ( MedicReward > 0 && ID_RPG_Base_PlayerController(Instigator.Controller) != none )
				{
					ID_RPG_Base_PlayerController(Instigator.Controller).GetStats().AddExperience(string(MedicReward*7));
					ID_RPG_Base_PlayerController(Instigator.Controller).AddCashGainedMessage(MedicReward, Healed.Location);
					ID_RPG_Base_PlayerController(Instigator.Controller).AddExperienceGainedMessage(string(MedicReward*7), Healed.Location);
				}
				
				if ( KFHumanPawn(Instigator) != none )
				{
					KFHumanPawn(Instigator).AlphaAmount = 255;
				}
				
				if( SPAS12(Instigator.Weapon) != none )
				{
					SPAS12(Instigator.Weapon).ClientSuccessfulHeal(Healed.PlayerReplicationInfo.PlayerName);
				}
			}
		}
	}
	else if( KFHumanPawn(Other) != none )
	{
		bHidden = true;
		SetPhysics(PHYS_None);
		return;
	}

	Explode(HitLocation,-vector(Rotation));
}

defaultproperties
{
     ShakeRotMag=(X=600.000000,Y=600.000000,Z=600.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(X=5.000000,Y=10.000000,Z=5.000000)
     ShakeOffsetRate=(X=300.000000,Y=300.000000,Z=300.000000)
     ShakeOffsetTime=3.500000
     RotMag=(X=700.000000,Y=700.000000,Z=700.000000)
     RotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     RotTime=6.000000
     OffsetMag=(X=5.000000,Y=10.000000,Z=7.000000)
     OffsetRate=(X=300.000000,Y=300.000000,Z=300.000000)
     OffsetTime=3.500000
     ExplosionSound=SoundGroup'KF_MP7Snd.Dart.MP7_DartImpact'
     HealBoostAmount=100
     StraightFlightTime=0.100000
     AmbientVolumeScale=2.000000
     Speed=10000.000000
     MaxSpeed=12500.000000
     Damage=650.000000
     DamageRadius=200.000000
     MomentumTransfer=125000.000000
     ExplosionDecal=Class'KFMod.ShotgunDecal'
     LightHue=25
     LightSaturation=100
     LightBrightness=250.000000
     LightRadius=10.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'KF_pickups2_Trip.Supers.MP7_Dart'
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     AmbientSound=Sound'KF_MP7Snd.Dart.MP7_DartFlyLoop'
     LifeSpan=10.000000
     bUnlit=False
     SoundVolume=128
     SoundRadius=250.000000
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     bNetNotify=True
     bBlockHitPointTraces=False
     ForceRadius=300.000000
     ForceScale=10.000000
}
