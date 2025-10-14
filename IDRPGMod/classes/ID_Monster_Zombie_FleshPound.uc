class ID_Monster_Zombie_FleshPound extends ID_Monster_Zombie_FleshPound_Base;

#exec OBJ LOAD FILE=KFPlayerSound.uax

simulated function PostNetBeginPlay()
{
	if (AvoidArea == None)
		AvoidArea = Spawn(class'ID_Monster_Zombie_FleshPound_AvoidArea',self);
	if (AvoidArea != None)
		AvoidArea.InitFor(Self);

	EnableChannelNotify ( 1,1);
	AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
	super.PostNetBeginPlay();
}

function SetMindControlled(bool bNewMindControlled)
{
	if( bNewMindControlled )
	{
		NumZCDHits++;

		if( NumZCDHits > 1 )
		{
			if( !IsInState('ChargeToMarker') )
			{
				GotoState('ChargeToMarker');
			}
			else
			{
				NumZCDHits = 1;
				if( IsInState('ChargeToMarker') )
				{
					GotoState('');
				}
			}
		}
		else
		{
			if( IsInState('ChargeToMarker') )
			{
				GotoState('');
			}
		}

		if( bNewMindControlled != bZedUnderControl )
		{
			GroundSpeed = OriginalGroundSpeed * 1.25;
			Health *= 1.25;
			HealthMax *= 1.25;
		}
	}
	else
	{
		NumZCDHits=0;
	}

	bZedUnderControl = bNewMindControlled;
}

function GivenNewMarker()
{
	if( bChargingPlayer && NumZCDHits > 1  )
	{
		GotoState('ChargeToMarker');
	}
	else
	{
		GotoState('');
	}
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
	if( Level.TimeSeconds - LastPainAnim < MinTimeBetweenPainAnims )
		return;

	if( !Controller.IsInState('WaitForAnim') && Damage >= 10 )
		PlayDirectionalHit(HitLocation);

	LastPainAnim = Level.TimeSeconds;

	if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
		return;

	LastPainSound = Level.TimeSeconds;
	PlaySound(HitSound[0], SLOT_Pain,1.25,,400);
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	local int BlockSlip;
	local float BlockChance;
	local Vector X,Y,Z, Dir;
	local bool bIsHeadShot;
	local float HeadShotCheckScale;

	GetAxes(Rotation, X,Y,Z);

	if( LastDamagedTime<Level.TimeSeconds )
		TwoSecondDamageTotal = 0;
	LastDamagedTime = Level.TimeSeconds+2;
	TwoSecondDamageTotal += Damage;

	HeadShotCheckScale = 1.0;

	if( class<DamTypeMelee>(damageType) != none )
	{
		HeadShotCheckScale *= 1.25;
	}

	bIsHeadShot = IsHeadShot(Hitlocation, normal(Momentum), 1.0);

	if ( DamageType != class 'DamTypeFrag' && DamageType != class 'DamTypeLaw' && DamageType != class 'DamTypePipeBomb'
		&& DamageType != class 'DamTypeM79Grenade' && DamageType != class 'DamTypeM32Grenade' )
	{
		if( bIsHeadShot && class<ID_RPG_Base_Weapon_DamageType>(damageType)!=none &&
			class<ID_RPG_Base_Weapon_DamageType>(damageType).default.HeadShotDamageMult >= 1.5 )
		{
			Damage *= 0.75;
		}
		else
		{
			Damage *= 0.5;
		}
	}
	else if (DamageType == class 'DamTypeFrag' || DamageType == class 'DamTypePipeBomb' )
	{
		Damage *= 2.0;
	}
	else if( DamageType == class 'DamTypeM79Grenade' || DamageType == class 'DamTypeM32Grenade' )
	{
		Damage *= 1.25;
	}

	if (Damage >= Health)
		PostNetReceive();

	if (!bDecapitated && TwoSecondDamageTotal > RageDamageThreshold && !bChargingPlayer &&
		(!(bCrispified && bBurnified) || bFrustrated) )
		StartCharging();

	Dir = -Normal(Location - hitlocation);
	BlockSlip = rand(5);

	if (AnimAction == 'PoundBlock')
		Damage *= BlockDamageReduction;

	if (Dir Dot X > 0.7 || Dir == vect(0,0,0))
		BlockChance = (Health / HealthMax * 100 ) - Damage * 0.25;

	if (damageType == class 'DamTypeVomit')
		Damage = 0;

	Super.takeDamage(Damage, instigatedBy, hitLocation, momentum, damageType,HitIndex) ;
}

simulated function DeviceGoRed()
{
	Skins[1]=Shader'KFCharacters.FPRedBloomShader';
}

simulated function DeviceGoNormal()
{
	Skins[1] = Shader'KFCharacters.FPAmberBloomShader';
}

function RangedAttack(Actor A)
{
	if ( bShotAnim || Physics == PHYS_Swimming)
		return;
	else if ( CanAttack(A) )
	{
		bShotAnim = true;
		SetAnimAction('Claw');
		return;
	}
}

function StartCharging()
{
	local float RageAnimDur;

	SetAnimAction('PoundRage');
	Acceleration = vect(0,0,0);
	bShotAnim = true;
	Velocity.X = 0;
	Velocity.Y = 0;
	Controller.GoToState('WaitForAnim');
	ID_Monster_Zombie_FleshPound_Controller(Controller).bUseFreezeHack = True;
	RageAnimDur = GetAnimDuration('PoundRage');
	ID_Monster_Zombie_FleshPound_Controller(Controller).SetPoundRageTimout(RageAnimDur);
	GoToState('BeginRaging');
}

state BeginRaging
{
	Ignores StartCharging;

	function bool CanGetOutOfWay()
	{
		return false;
	}

	simulated function bool HitCanInterruptAction()
	{
		return false;
	}

	function Tick( float Delta )
	{
		Acceleration = vect(0,0,0);

		global.Tick(Delta);
	}

Begin:
	Sleep(GetAnimDuration('PoundRage'));
	GotoState('RageCharging');
}


simulated function SetBurningBehavior()
{
	if( bFrustrated || bChargingPlayer )
	{
		return;
	}

	super.SetBurningBehavior();
}

state RageCharging
{
Ignores StartCharging;

	function PlayDirectionalHit(Vector HitLoc)
	{
		if( !bShotAnim )
		{
			super.PlayDirectionalHit(HitLoc);
		}
	}

	function bool CanGetOutOfWay()
	{
		return false;
	}

	function bool CanSpeedAdjust()
	{
		return false;
	}

	function BeginState()
	{
		local float DifficultyModifier;

		bChargingPlayer = true;
		if( Level.NetMode!=NM_DedicatedServer )
			ClientChargingAnims();

		DifficultyModifier = 1.25;

		RageEndTime = (Level.TimeSeconds + 5 * DifficultyModifier) + (FRand() * 6 * DifficultyModifier);
		NetUpdateTime = Level.TimeSeconds - 1;
	}

	function EndState()
	{
		bChargingPlayer = False;
		bFrustrated = false;

		ID_Monster_Zombie_FleshPound_Controller(Controller).RageFrustrationTimer = 0;

		if( Health>0 )
		{
			GroundSpeed = GetOriginalGroundSpeed();
		}

		if( Level.NetMode!=NM_DedicatedServer )
			ClientChargingAnims();

		NetUpdateTime = Level.TimeSeconds - 1;
	}

	function Tick( float Delta )
	{
		if( !bShotAnim )
		{
			GroundSpeed = OriginalGroundSpeed * 2.3;
			if( !bFrustrated && !bZedUnderControl && Level.TimeSeconds>RageEndTime )
			{
				GoToState('');
			}
		}

		if( Role == ROLE_Authority && bShotAnim)
		{
			if( LookTarget!=None )
			{
				Acceleration = AccelRate * Normal(LookTarget.Location - Location);
			}
		}

		global.Tick(Delta);
	}

	function Bump( Actor Other )
	{
		local float RageBumpDamage;
		local KFMonster KFMonst;

		KFMonst = KFMonster(Other);

		if( !bShotAnim && KFMonst!=None && ID_Monster_Zombie_FleshPound(Other)==None && Pawn(Other).Health>0 )
		{
			if( FRand() < 0.4 )
			{
				RageBumpDamage = 501;
			}
			else
			{
				RageBumpDamage = 450;
			}

			RageBumpDamage *= KFMonst.PoundRageBumpDamScale;

			Other.TakeDamage(RageBumpDamage, self, Other.Location, Velocity * Other.Mass, class'DamTypePoundCrushed');
		}
		else Global.Bump(Other);
	}

	function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
		local bool RetVal,bWasEnemy;

		bWasEnemy = (Controller.Target==Controller.Enemy);
		RetVal = Super.MeleeDamageTarget(hitdamage*1.75, pushdir*3);
		if( RetVal && bWasEnemy )
			GoToState('');
		return RetVal;
	}
}

state ChargeToMarker extends RageCharging
{
Ignores StartCharging;

	function Tick( float Delta )
	{
		if( !bShotAnim )
		{
			GroundSpeed = OriginalGroundSpeed * 2.3;
			if( !bFrustrated && !bZedUnderControl && Level.TimeSeconds>RageEndTime )
			{
				GoToState('');
			}
		}

		if( Role == ROLE_Authority && bShotAnim)
		{
			if( LookTarget!=None )
			{
				Acceleration = AccelRate * Normal(LookTarget.Location - Location);
			}
		}

		global.Tick(Delta);
	}
}

simulated function PostNetReceive()
{
	if( bClientCharge!=bChargingPlayer )
	{
		bClientCharge = bChargingPlayer;
		if (bChargingPlayer)
		{
			MovementAnims[0]=ChargingAnim;
			MeleeAnims[0]='FPRageAttack';
			MeleeAnims[1]='FPRageAttack';
			MeleeAnims[2]='FPRageAttack';
			DeviceGoRed();
		}
		else
		{
			MovementAnims[0]=default.MovementAnims[0];
			MeleeAnims[0]=default.MeleeAnims[0];
			MeleeAnims[1]=default.MeleeAnims[1];
			MeleeAnims[2]=default.MeleeAnims[2];
			DeviceGoNormal();
		}
	}
}

simulated function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
	Super.PlayDyingAnimation(DamageType,HitLoc);
	if( Level.NetMode!=NM_DedicatedServer )
		DeviceGoNormal();
}

simulated function ClientChargingAnims()
{
	PostNetReceive();
}

function ClawDamageTarget()
{
	local vector PushDir;
	local KFHumanPawn HumanTarget;
	local KFPlayerController HumanTargetController;
	local float UsedMeleeDamage;
	local name  Sequence;
	local float Frame, Rate;

	GetAnimParams( ExpectingChannel, Sequence, Frame, Rate );

	if( MeleeDamage > 1 )
	{
	  UsedMeleeDamage = (MeleeDamage - (MeleeDamage * 0.05)) + (MeleeDamage * (FRand() * 0.1));
	}
	else
	{
	  UsedMeleeDamage = MeleeDamage;
	}

	if( Sequence == 'PoundAttack1' )
	{
		UsedMeleeDamage *= 0.5;
	}
	else if( Sequence == 'PoundAttack2' )
	{
		UsedMeleeDamage *= 0.25;
	}

	if(Controller!=none && Controller.Target!=none)
	{
		PushDir = (damageForce * Normal(Controller.Target.Location - Location));
	}
	else
	{
		PushDir = damageForce * vector(Rotation);
	}
	if ( MeleeDamageTarget( UsedMeleeDamage, PushDir))
	{
		HumanTarget = KFHumanPawn(Controller.Target);
		if( HumanTarget!=None )
			HumanTargetController = KFPlayerController(HumanTarget.Controller);
		if( HumanTargetController!=None )
			HumanTargetController.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
		PlaySound(MeleeAttackHitSound, SLOT_Interact, 1.25);
	}
}

function SpinDamage(actor Target)
{
	local vector HitLocation;
	local Name TearBone;
	local Float dummy;
	local float DamageAmount;
	local vector PushDir;
	local KFHumanPawn HumanTarget;

	if(target==none)
		return;

	PushDir = (damageForce * Normal(Target.Location - Location));
	damageamount = (SpinDamConst + rand(SpinDamRand) );

	if (Target.IsA('KFHumanPawn') && Pawn(Target).Health <= DamageAmount)
	{
		KFHumanPawn(Target).RagDeathVel *= 3;
		KFHumanPawn(Target).RagDeathUpKick *= 1.5;
	}

	if (Target !=none && Target.IsA('KFDoorMover'))
	{
		Target.TakeDamage(DamageAmount , self ,HitLocation,pushdir, class 'KFmod.ZombieMeleeDamage');
		PlaySound(MeleeAttackHitSound, SLOT_Interact, 1.25);
	}

	if (KFHumanPawn(Target)!=none)
	{
		HumanTarget = KFHumanPawn(Target);
		if (HumanTarget.Controller != none)
			HumanTarget.Controller.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

		KFHumanPawn(Target).TakeDamage(DamageAmount, self ,HitLocation,pushdir, class 'KFmod.ZombieMeleeDamage');

		if (KFHumanPawn(Target).Health <=0)
		{
			KFHumanPawn(Target).SpawnGibs(rotator(pushdir), 1);
			TearBone=KFPawn(Target).GetClosestBone(HitLocation,Velocity,dummy);
			KFHumanPawn(Controller.Target).HideBone(TearBone);
		}
	}
}

simulated function int DoAnimAction( name AnimName )
{
	if( AnimName=='PoundAttack1' || AnimName=='PoundAttack2' || AnimName=='PoundAttack3'
		||AnimName=='FPRageAttack' || AnimName=='ZombieFireGun' )
	{
		AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
		PlayAnim(AnimName,, 0.1, 1);
		Return 1;
	}
	Return Super.DoAnimAction(AnimName);
}

simulated event SetAnimAction(name NewAction)
{
	local int meleeAnimIndex;

	if( NewAction=='' )
		Return;
	if(NewAction == 'Claw')
	{
		meleeAnimIndex = Rand(3);
		NewAction = meleeAnims[meleeAnimIndex];
		CurrentDamtype = ZombieDamType[meleeAnimIndex];
	}
	else if( NewAction == 'DoorBash' )
	{
	  CurrentDamtype = ZombieDamType[Rand(3)];
	}
	ExpectingChannel = DoAnimAction(NewAction);

	if( AnimNeedsWait(NewAction) )
	{
		bWaitForAnim = true;
	}

	if( Level.NetMode!=NM_Client )
	{
		AnimAction = NewAction;
		bResetAnimAct = True;
		ResetAnimActTime = Level.TimeSeconds+0.3;
	}
}

simulated function bool AnimNeedsWait(name TestAnim)
{
	if( TestAnim == 'PoundRage' || TestAnim == 'DoorBash' )
	{
		return true;
	}

	return false;
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if( Role == ROLE_Authority && bShotAnim)
	{
		if( LookTarget!=None )
		{
			Acceleration = AccelRate * Normal(LookTarget.Location - Location);
		}
	}
}


function bool FlipOver()
{
	Return False;
}

function bool SameSpeciesAs(Pawn P)
{
	return (ID_Monster_Zombie_FleshPound(P)!=None);
}

simulated function Destroyed()
{
	if( AvoidArea!=None )
		AvoidArea.Destroy();

	Super.Destroyed();
}

defaultproperties
{
     DetachedArmClass=Class'KFChar.SeveredArmPound'
     DetachedLegClass=Class'KFChar.SeveredLegPound'
     DetachedHeadClass=Class'KFChar.SeveredHeadPound'
     ControllerClass=Class'IDRPGMod.ID_Monster_Zombie_FleshPound_Controller'
}
