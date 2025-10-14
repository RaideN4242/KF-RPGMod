class CivilNadeProj extends Nade;

var  float   ShakeTime;
var  float   ShakeFadeTime;
var  float	ShakeEffectScalar;
var  float	MinShakeEffectScale;
var  float	ScreamBlurScale;
var  rotator RotMag1;
var  float   RotRate1;
var  vector  OffsetMag1;
var  float   OffsetRate1;

function Timer()
{	
		
	if( !bHidden )
	{
		Explode(Location, vect(0,0,1));
	}
	else
	{
		Destroy();
	}
}

simulated function DoShakeEffect()
{
	local PlayerController PC;
	local float Dist, scale, BlurScale;

	//viewshake
	if (Level.NetMode != NM_DedicatedServer)
	{
		PC = Level.GetLocalPlayerController();
		if (PC != None && PC.ViewTarget != None)
		{
			Dist = VSize(Location - PC.ViewTarget.Location);
			if (Dist < DamageRadius )
			{
				scale = (DamageRadius - Dist) / (DamageRadius);
				scale *= ShakeEffectScalar;
				BlurScale = scale;

				// Reduce blur if there is something between us and the siren
				if( !FastTrace(PC.ViewTarget.Location,Location) )
				{
					scale *= 0.25;
					BlurScale = scale;
				}
				else
				{
					scale = Lerp(scale,MinShakeEffectScale,1.0);
				}

				PC.SetAmbientShake(Level.TimeSeconds + ShakeFadeTime, ShakeTime, OffsetMag1 * Scale, OffsetRate1, RotMag1 * Scale, RotRate1);

				if( KFHumanPawn(PC.ViewTarget) != none )
				{
					KFHumanPawn(PC.ViewTarget).AddBlur(ShakeTime, BlurScale * ScreamBlurScale);
				}				
			}
		}
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController  LocalPlayer;
	//local Projectile P;
	//local byte i;

	bHasExploded = True;
	Spawn(Class'fbemt',,, Location, rotator(vect(0,0,1)));
	BlowUp(HitLocation);

	PlaySound(ExplodeSounds[0],,2.0);

	// Shrapnel
	/*for( i=Rand(6); i<10; i++ )
	{
		P = Spawn(ShrapnelClass,,,,RotRand(True));
		if( P!=None )
			P.RemoteRole = ROLE_None;
	}*/
	
	if ( EffectIsRelevant(Location,false) )
	{
		//Spawn(Class'MarinesLight',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}
	
	LocalPlayer = Level.GetLocalPlayerController();
	
	if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (DamageRadius * 1.5)) )
		LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);		
	
	Destroy();
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	local Vector VNorm;
	local PlayerController PC;

	if ( (Pawn(Wall) != None) || (GameObjective(Wall) != None) )
	{
		Explode(Location, HitNormal);
		return;
	}

	if (!bTimerSet)
	{
		SetTimer(ExplodeTimer, false);
		bTimerSet = true;
	}

	// Reflect off Wall w/damping
	VNorm = (Velocity dot HitNormal) * HitNormal;
	Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

	RandSpin(100000);
	DesiredRotation.Roll = 0;
	RotationRate.Roll = 0;
	Speed = VSize(Velocity);

	if ( Speed < 20 )
	{
		bBounce = False;
		PrePivot.Z = -1.5;
			SetPhysics(PHYS_None);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);

		if( Fear == none )
		{
			Fear = Spawn(class'AvoidMarker');
			Fear.SetCollisionSize(DamageRadius,DamageRadius);
			Fear.StartleBots();
		}

		if ( Trail != None )
			Trail.mRegen = false; // stop the emitter from regenerating		
	}
	else
	{
		if ( (Level.NetMode != NM_DedicatedServer) && (Speed > 50) )
			PlaySound(ImpactSound, SLOT_Misc );
		else
		{
			bFixedRotationDir = false;
			bRotateToDesired = true;
			DesiredRotation.Pitch = 0;
			RotationRate.Pitch = 50000;
		}
		if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.TimeSeconds - LastSparkTime > 0.5) && EffectIsRelevant(Location,false) )
		{
			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
				Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
			LastSparkTime = Level.TimeSeconds;
		}
	}
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	//local int NumKilled;
	local KFMonster KFMonsterVictim;
	local Pawn P;
	local KFPawn KFP;
	local array<Pawn> CheckedPawns;
	local int i;
	local bool bAlreadyChecked;
	//local float DamageRadius1;


	if ( bHurtEntry )
		return;

	bHurtEntry = true;

	foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
		&& ExtendedZCollision(Victims)==None )
		{
			if( (Instigator==None || Instigator.Health<=0) && KFPawn(Victims)!=None )
				Continue;
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

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
					DamageAmount = 10;
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

			Victims.TakeDamage(DamageAmount,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius)
			* dir,vect(0,0,0),DamageType);
			
			if(ID_RPG_Base_Monster(Victims)!=None)
				ID_RPG_Base_Monster(Victims).SetShocked(6,Instigator);			
				
			if(KFPawn(Victims)!=None)
			{				
				DoShakeEffect();
				playercontroller(KFPawn(Victims).controller).clientplaysound(sound(DynamicLoadObject("DZResPack.Beep", class'sound')),false,10.0f,SLOT_None);
			}

			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			{
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
			}
		}
	}

	bHurtEntry = false;
}

defaultproperties
{
     ShakeTime=2.000000
     ShakeFadeTime=0.250000
     ShakeEffectScalar=1.000000
     MinShakeEffectScale=0.600000
     ScreamBlurScale=0.850000
     RotMag1=(Pitch=150,Yaw=150,Roll=150)
     RotRate1=500.000000
     OffsetMag1=(Y=5.000000,Z=1.000000)
     OffsetRate1=500.000000
     ExplodeSounds(0)=Sound'DZResPack.Bang'
     Speed=1000.000000
     MaxSpeed=1500.000000
     Damage=15.000000
     MyDamageType=Class'IDRPGMod.DamTypeCivNade'
     StaticMesh=StaticMesh'DZResPack.FlashBang3rdMesh'
}
