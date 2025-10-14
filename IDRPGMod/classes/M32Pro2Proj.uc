class M32Pro2Proj extends M79GrenadeProjectile;

var()   int	HealBoostAmount;// How much we heal a player by default with the medic nade
var	bool	bNeedToPlayEffects; // Whether or not effects have been played yet
var	int	TotalHeals;	// The total number of times this nade has healed (or hurt enemies)
var()   int	MaxHeals;	  // The total number of times this nade will heal (or hurt enemies) until its done healing
var	float   NextHealTime;   // The next time that this nade will heal friendlies or hurt enemies
var()   float   HealInterval;   // How often to do healing
var localized   string  SuccessfulHealMessage;
var bool isBlow;

replication
{
	reliable if(Role == ROLE_Authority)
		bNeedToPlayEffects;
}

//no smoke
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

//no shake
function ShakeView();

simulated function PostNetReceive()
{
	super(ROBallisticProjectile).PostNetReceive();
	if( !bHasExploded && bNeedToPlayEffects )
	{
		bNeedToPlayEffects = false;
		Explode(Location, vect(0,0,1));
	}
}

function Timer()
{
	if( !bHidden )
	{
		if( !bHasExploded )
		{
			Explode(Location, vect(0,0,1));
		}
	}
	else if( bDisintegrated )
	{
		AmbientSound=none;
		Destroy();
	}
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	if( Instigator != none )
	{
		OrigLoc = Instigator.Location;
	}

	super(Projectile).HitWall(HitNormal,Wall);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if( bHasExploded )
		return;
		
	bHasExploded = True;
	BlowUp(HitLocation);

	PlaySound(ExplosionSound,,TransientSoundVolume);
	
	if( Role == ROLE_Authority )
	{
		bNeedToPlayEffects = true;		
		AmbientSound=Sound'Inf_WeaponsTwo.smoke_loop';
	}

	if ( EffectIsRelevant(Location,false) && !isBlow)
	{
		isBlow=true;
		Spawn(Class'BNadeHealing',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
		ExplosionDecal=none;		
	}
}

simulated function Disintegrate(vector HitLocation, vector HitNormal);

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation );

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( Other == none || Other == Instigator || Other.Base == Instigator )
		return;

	if( KFBulletWhipAttachment(Other) != none )
	{
		return;
	}

	if( KFHumanPawn(Other) != none && Instigator != none
		&& KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex )
	{
		return;
	}

	if( Instigator != none )
	{
		OrigLoc = Instigator.Location;
	}

	Explode(HitLocation,Normal(HitLocation-Other.Location));
}

function Tick( float DeltaTime )
{
	if( Role < ROLE_Authority )
	{
		return;
	}

	if( TotalHeals < MaxHeals && NextHealTime > 0 &&  NextHealTime < Level.TimeSeconds )
	{
		TotalHeals += 1;

		HealOrHurt(Damage,DamageRadius, MyDamageType, MomentumTransfer, Location);

		if( TotalHeals >= MaxHeals )
		{
			AmbientSound=none;
		}
	}
}

simulated function Landed( vector HitNormal )
{
	SetPhysics(PHYS_None);

	if( !bDud )
	{
	  Explode(Location,HitNormal);
	}
	else
	{
	  Destroy();
	}
}

simulated function BlowUp(vector HitLocation)
{
	HealOrHurt(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	if ( Role == ROLE_Authority )
	{
		MakeNoise(1.0);		
	}
}

function HealOrHurt(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
	local actor Victims;
	local float damageScale;
//	local vector dirs;
//	local int NumKilled;
	local KFMonster KFMonsterVictim;
	local Pawn P;
	local KFPawn KFP;
	local array<Pawn> CheckedPawns;
	local int i;
	local bool bAlreadyChecked;
	// Healing
	local KFPlayerReplicationInfo PRI;
//	local int MedicReward;
//	local float HealSum; // for modifying based on perks	

	if ( bHurtEntry )
		return;
		
	//log("Heal"@Level.TimeSeconds);

	NextHealTime = Level.TimeSeconds + HealInterval;

	bHurtEntry = true;

	foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
		&& ExtendedZCollision(Victims)==None )
		{
			if( (Instigator==None || Instigator.Health<=0) && KFPawn(Victims)!=None )
				Continue;

			damageScale = 1.0;

			if ( Instigator == None || Instigator.Controller == None )
			{
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			}

			P = Pawn(Victims);

			if( P != none )
			{
				for (i = 0; i < CheckedPawns.Length; i++)
				{
					if (CheckedPawns[i] == P)
					{
						bAlreadyChecked = true;
						break;
					}
				}

				if( bAlreadyChecked )
				{
					bAlreadyChecked = false;
					P = none;
					continue;
				}

				KFMonsterVictim = KFMonster(Victims);

				if( KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
				{
					KFMonsterVictim = none;
				}

				KFP = KFPawn(Victims);

				if( KFMonsterVictim != none )
				{
					damageScale *= KFMonsterVictim.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
				}
				else if( KFP != none )
				{
					damageScale *= KFP.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
				}

				CheckedPawns[CheckedPawns.Length] = P;

				if ( damageScale <= 0)
				{
					P = none;
					continue;
				}
				else
				{
					//Victims = P;
					P = none;
				}
			}
			else
			{
				continue;
			}

			if( KFMonsterVictim != none )
			{
				//log(Level.TimeSeconds@"Hurting "$Victims$" for "$(damageScale * DamageAmount)$" damage");

				/*if( Pawn(Victims) != none && Pawn(Victims).Health > 0 )
				{
					Victims.TakeDamage(damageScale * DamageAmount,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius)
					* dirs,(damageScale * Momentum * dirs),DamageType);

					if( Role == ROLE_Authority && KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
					{
						NumKilled++;
					}
				}*/
			}
			else if(KFP!=None)
			{
				if( Instigator != none && KFP.ShieldStrength<ID_RPG_Base_HumanPawn(KFP).MaxShieldStrength )
				{					
					KFP.ShieldStrength+=HealBoostAmount;
					
					//log("KFP.ShieldStrength"@KFP.ShieldStrength);
					
					if(KFP.ShieldStrength>ID_RPG_Base_HumanPawn(KFP).MaxShieldStrength)
						KFP.ShieldStrength=ID_RPG_Base_HumanPawn(KFP).MaxShieldStrength;

					if ( PRI != None )
					{
						if( PlayerController(Instigator.Controller) != none )
						{
							PlayerController(Instigator.Controller).ClientMessage(SuccessfulHealMessage@KFP.PlayerReplicationInfo.PlayerName, 'CriticalEvent');
						}
					}
				}
			}

			KFP = none;
		}		
	}

	bHurtEntry = false;
}

defaultproperties
{
     HealBoostAmount=10
     MaxHeals=10
     HealInterval=1.000000
     SuccessfulHealMessage="You repaired "
     ArmDistSquared=0.000000
     Damage=0.000000
     DamageRadius=300.000000
     MomentumTransfer=5000.000000
     MyDamageType=Class'IDRPGMod.ID_Weapon_Base_M32GL_DamageType'
     ExplosionDecal=Class'KFMod.MedicNadeDecal'
}
