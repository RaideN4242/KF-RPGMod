class ID_Monster_Zombie_Patty extends ID_Monster_Zombie_Patty_Base;

#exec OBJ LOAD FILE=KFPatch2.utx
#exec OBJ LOAD FILE=KF_Specimens_Trip_T.utx

var BossHPNeedle CurrentNeedle;

simulated function CalcAmbientRelevancyScale()
{
	CustomAmbientRelevancyScale=3000/(100*SoundRadius);
}

function ZombieMoan()
{
	if(!bShotAnim)
		Super.ZombieMoan();
}

function PatriarchKnockDown()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_KnockedDown', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchEntrance()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Entrance', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchVictory()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Victory', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchMGPreFire()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_WarnGun', SLOT_Misc, 2.0,true,1000.0);
}

function PatriarchMisslePreFire()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_WarnRocket', SLOT_Misc, 2.0,true,1000.0);
}

simulated function SetBurningBehavior();
simulated function UnSetBurningBehavior();
function bool CanGetOutOfWay()
{
	return false;
}

simulated function Tick(float DeltaTime)
{
	local KFHumanPawn HP;

	Super.Tick(DeltaTime);

	if(Role==ROLE_Authority)
	{
	  PipeBombDamageScale-=DeltaTime*0.33;

	  if(PipeBombDamageScale<0)
	  {
		  PipeBombDamageScale=0;
	  }
	}

	if(Level.NetMode==NM_DedicatedServer)
		Return;

	bSpecialCalcView=bIsBossView;
	if(bCloaked && Level.TimeSeconds>LastCheckTimes)
	{
		LastCheckTimes=Level.TimeSeconds+0.8;
		ForEach VisibleCollidingActors(Class'KFHumanPawn',HP,1000,Location)
		{
			if(HP.Health<=0 || !HP.ShowStalkers())
				continue;

			if(!bSpotted)
			{
				bSpotted=True;
				CloakBoss();
			}
			Return;
		}

		if(bSpotted)
		{
			bSpotted=False;
			bUnlit=false;
			CloakBoss();
		}
	}
}
simulated function CloakBoss()
{
	local Controller C;
	local int Index;

	if(bSpotted)
	{
		Visibility=120;
		if(Level.NetMode==NM_DedicatedServer)
			Return;
		Skins[0]=Finalblend'KFX.StalkerGlow';
		Skins[1]=Finalblend'KFX.StalkerGlow';
		bUnlit=true;
		return;
	}

	Visibility=1;
	bCloaked=true;
	if(Level.NetMode!=NM_Client)
	{
		For(C=Level.ControllerList; C!=None; C=C.NextController)
		{
			if(C.bIsPlayer && C.Enemy==Self)
				C.Enemy=None;
		}
	}
	if(Level.NetMode==NM_DedicatedServer)
		Return;

	Skins[0]=Shader'KF_Specimens_Trip_T.patriarch_invisible_gun';
	Skins[1]=Shader'KF_Specimens_Trip_T.patriarch_invisible';

	if(PlayerShadow!=none)
		PlayerShadow.bShadowActive=false;

	Projectors.Remove(0, Projectors.Length);
	bAcceptsProjectors=false;
	SetOverlayMaterial(FinalBlend'KF_Specimens_Trip_T.patriarch_fizzle_FB', 1.0, true);

	if(FRand()<0.1)
	{
		Index=Rand(Level.Game.NumPlayers);

		for(C=Level.ControllerList; C!=none; C=C.NextController)
		{
			if(PlayerController(C)!=none)
			{
				if(Index==0)
				{
					PlayerController(C).Speech('AUTO', 8, "");
					break;
				}

				Index--;
			}
		}
	}
}

simulated function UnCloakBoss()
{
	Visibility=default.Visibility;
	bCloaked=false;
	bSpotted=False;
	bUnlit=False;
	if(Level.NetMode==NM_DedicatedServer)
		Return;
	Skins=Default.Skins;

	if(PlayerShadow!=none)
		PlayerShadow.bShadowActive=true;

	bAcceptsProjectors=true;
	SetOverlayMaterial(none, 0.0, true);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if(Role<ROLE_Authority)
	{
		return;
	}

	MGDamage=default.MGDamage;
	MGDamage+=MGDamage*DmgPerLvl*(Lvl-1);

	HealingLevels[0]=Health/1.25;
	HealingLevels[1]=Health/2;
	HealingLevels[2]=Health/3;

	HealingAmount=Health/3; 
}

function bool MakeGrandEntry()
{
	bShotAnim=true;
	Acceleration=vect(0,0,0);
	SetAnimAction('Entrance');
	HandleWaitForAnim('Entrance');
	GotoState('MakingEntrance');

	return True;
}

state MakingEntrance
{
	Ignores RangedAttack;

	function Tick(float Delta)
	{
		Acceleration=vect(0,0,0);

		global.Tick(Delta);
	}

Begin:
	Sleep(GetAnimDuration('Entrance'));
	GotoState('InitialSneak');
}

simulated function Destroyed()
{
	if(mTracer!=None)
		mTracer.Destroy();
	if(mMuzzleFlash!=None)
		mMuzzleFlash.Destroy();
	Super.Destroyed();
}

simulated Function PostNetBeginPlay()
{
	EnableChannelNotify (1,1);
	AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
	super.PostNetBeginPlay();
	TraceHitPos=vect(0,0,0);
	bNetNotify=True;
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType>DamageType)
{
	if(Level.TimeSeconds-LastPainAnim<MinTimeBetweenPainAnims)
		return;

	if(Damage>=150 || (DamageType.name=='DamTypeStunNade' && rand(5)>3) || (DamageType.name=='ID_Weapon_Base_Crossbow_DamageType_HeadShot' && Damage>=200))
		PlayDirectionalHit(HitLocation);

	LastPainAnim=Level.TimeSeconds;

	if(Level.TimeSeconds-LastPainSound<MinTimeBetweenPainSounds)
		return;

	LastPainSound=Level.TimeSeconds;
	PlaySound(HitSound[0], SLOT_Pain,2*TransientSoundVolume,,400);
}

function bool OnlyEnemyAround(Pawn Other)
{
	local Controller C;

	For(C=Level.ControllerList; C!=None; C=C.NextController)
	{
		if(C.bIsPlayer && C.Pawn!=None && C.Pawn!=Other && ((VSize(C.Pawn.Location-Location)<1500 && FastTrace(C.Pawn.Location,Location))
		|| (VSize(C.Pawn.Location-Other.Location)<1000 && FastTrace(C.Pawn.Location,Other.Location))))
			Return False;
	}
	Return True;
}

function bool IsCloseEnuf(Actor A)
{
	local vector V;

	if(A==None)
		Return False;
	V=A.Location-Location;
	if(Abs(V.Z)>(CollisionHeight+A.CollisionHeight))
		Return False;
	V.Z=0;
	Return (VSize(V)<(CollisionRadius+A.CollisionRadius+25));
}

function RangedAttack(Actor A)
{
	local float D;
	local bool bOnlyE;
	local bool bDesireChainGun;

	if(Controller.LineOfSightTo(A) && FRand()<0.15 && LastChainGunTime<Level.TimeSeconds)
	{
		bDesireChainGun=true;
	}

	if(bShotAnim)
		return;
	D=VSize(A.Location-Location);
	bOnlyE=(Pawn(A)!=None && OnlyEnemyAround(Pawn(A)));
	if(IsCloseEnuf(A))
	{
		bShotAnim=true;
		if(Health>1500 && Pawn(A)!=None && FRand()<0.5)
		{
			SetAnimAction('MeleeImpale');
		}
		else
		{
			SetAnimAction('MeleeClaw');
		}
	}
	else if(Level.TimeSeconds-LastSneakedTime>20.0)
	{
		if(FRand()<0.3)
		{
			LastSneakedTime=Level.TimeSeconds;
			Return;
		}
		SetAnimAction('transition');
		GoToState('SneakAround');
	}
	else if(bChargingPlayer && (bOnlyE || D<200))
		Return;
	else if(!bDesireChainGun && !bChargingPlayer && (D<300 || (D<700 && bOnlyE)) &&
		(Level.TimeSeconds-LastChargeTime>(5.0+5.0*FRand())))
	{
		SetAnimAction('transition');
		GoToState('Charging');
	}
	else if(LastMissileTime<Level.TimeSeconds && D>500)
	{
		if(!Controller.LineOfSightTo(A) || FRand()>0.75)
		{
			LastMissileTime=Level.TimeSeconds+FRand()*5;
			Return;
		}

		LastMissileTime=Level.TimeSeconds+10+FRand()*15;

		bShotAnim=true;
		Acceleration=vect(0,0,0);
		SetAnimAction('PreFireMissile');

		HandleWaitForAnim('PreFireMissile');
		GoToState('FireMissile');
	}
	else if(!bWaitForAnim && !bShotAnim && LastChainGunTime<Level.TimeSeconds)
	{
		if(!Controller.LineOfSightTo(A) || FRand()>0.85)
		{
			LastChainGunTime=Level.TimeSeconds+FRand()*4;
			Return;
		}

		LastChainGunTime=Level.TimeSeconds+5+FRand()*10;

		bShotAnim=true;
		Acceleration=vect(0,0,0);
		SetAnimAction('PreFireMG');

		HandleWaitForAnim('PreFireMG');
		MGFireCounter= Rand(60)+35;

		GoToState('FireChaingun');
	}
}

event Bump(actor Other)
{
	Super(Monster).Bump(Other);
	if(Other==none)
		return;

	if(Other.IsA('NetKActor') && Physics!=PHYS_Falling && !bShotAnim && Abs(Other.Location.Z-Location.Z)<(CollisionHeight+Other.CollisionHeight))
	{
		Controller.Target=Other;
		Controller.Focus=Other;
		bShotAnim=true;
		Acceleration=(Other.Location-Location);
		SetAnimAction('MeleeClaw');
		HandleWaitForAnim('MeleeClaw');
	}
}

simulated function AddTraceHitFX(vector HitPos)
{
	local vector Start,SpawnVel,SpawnDir;
	local float hitDist;

	Start=GetBoneCoords('tip').Origin;
	if(mTracer==None)
		mTracer=Spawn(Class'KFMod.KFNewTracer',,,Start);
	else mTracer.SetLocation(Start);
	if(mMuzzleFlash==None)
	{
		mMuzzleFlash=Spawn(Class'MuzzleFlash3rdMG');
		AttachToBone(mMuzzleFlash, 'tip');
	}
	else mMuzzleFlash.SpawnParticle(1);
	hitDist=VSize(HitPos-Start)-50.f;

	if(hitDist>10)
	{
		SpawnDir=Normal(HitPos-Start);
		SpawnVel=SpawnDir*10000.f;
		mTracer.Emitters[0].StartVelocityRange.X.Min=SpawnVel.X;
		mTracer.Emitters[0].StartVelocityRange.X.Max=SpawnVel.X;
		mTracer.Emitters[0].StartVelocityRange.Y.Min=SpawnVel.Y;
		mTracer.Emitters[0].StartVelocityRange.Y.Max=SpawnVel.Y;
		mTracer.Emitters[0].StartVelocityRange.Z.Min=SpawnVel.Z;
		mTracer.Emitters[0].StartVelocityRange.Z.Max=SpawnVel.Z;
		mTracer.Emitters[0].LifetimeRange.Min=hitDist/10000.f;
		mTracer.Emitters[0].LifetimeRange.Max=mTracer.Emitters[0].LifetimeRange.Min;
		mTracer.SpawnParticle(1);
	}
	Instigator=Self;

	if(HitPos!=vect(0,0,0))
	{
		Spawn(class'ROBulletHitEffect',,, HitPos, Rotator(Normal(HitPos-Start)));
	}
}

simulated function AnimEnd(int Channel)
{
	local name Sequence;
	local float Frame, Rate;

	if(Level.NetMode==NM_Client && bMinigunning)
	{
		GetAnimParams(Channel, Sequence, Frame, Rate);

		if(Sequence!='PreFireMG' && Sequence!='FireMG')
		{
			Super.AnimEnd(Channel);
			return;
		}

		PlayAnim('FireMG');
		bWaitForAnim=true;
		bShotAnim=true;
		IdleTime=Level.TimeSeconds;
	}
	else Super.AnimEnd(Channel);
}

state FireChaingun
{
	function RangedAttack(Actor A)
	{
		Controller.Target=A;
		Controller.Focus=A;
	}

	function bool ShouldChargeFromDamage()
	{
		return false;
	}

	function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType>damageType, optional int HitIndex)
	{
		local float EnemyDistSq, DamagerDistSq;

		global.TakeDamage(Damage,instigatedBy,hitlocation,vect(0,0,0),damageType);

		if(InstigatedBy!=none)
		{
			DamagerDistSq=VSizeSquared(Location-InstigatedBy.Location);

			if((ChargeDamage>200 && DamagerDistSq<(500*500)) || DamagerDistSq<(100*100))
			{
				SetAnimAction('transition');
				GoToState('Charging');
				return;
			}
		}

		if(Controller.Enemy!=none && InstigatedBy!=none && InstigatedBy!=Controller.Enemy)
		{
			EnemyDistSq=VSizeSquared(Location-Controller.Enemy.Location);
			DamagerDistSq=VSizeSquared(Location-InstigatedBy.Location);
		}

		if(InstigatedBy!=none && (DamagerDistSq<EnemyDistSq || Controller.Enemy==none))
		{
			MonsterController(Controller).ChangeEnemy(InstigatedBy,Controller.CanSee(InstigatedBy));
			Controller.Target=InstigatedBy;
			Controller.Focus=InstigatedBy;

			if(DamagerDistSq<(500*500))
			{
				SetAnimAction('transition');
				GoToState('Charging');
			}
		}
	}

	function EndState()
	{
		TraceHitPos=vect(0,0,0);
		bMinigunning=False;

		AmbientSound=default.AmbientSound;
		SoundVolume=default.SoundVolume;
		SoundRadius=default.SoundRadius;
		MGFireCounter=0;

		LastChainGunTime=Level.TimeSeconds+5+(FRand()*10);
	}

	function BeginState()
	{
		bFireAtWill=False;
		Acceleration=vect(0,0,0);
		MGLostSightTimeout=0.0;
		bMinigunning=True;
	}

	function AnimEnd(int Channel)
	{
		if(MGFireCounter<=0)
		{
			bShotAnim=true;
			Acceleration=vect(0,0,0);
			SetAnimAction('FireEndMG');
			HandleWaitForAnim('FireEndMG');
			GoToState('');
		}
		else
		{
			if(Controller.Enemy!=none)
			{
				if(Controller.LineOfSightTo(Controller.Enemy) && FastTrace(GetBoneCoords('tip').Origin,Controller.Enemy.Location))
				{
					MGLostSightTimeout=0.0;
					Controller.Focus=Controller.Enemy;
					Controller.FocalPoint=Controller.Enemy.Location;
				}
				else
				{
					MGLostSightTimeout=Level.TimeSeconds+(0.25+FRand()*0.35);
					Controller.Focus=None;
				}

				Controller.Target=Controller.Enemy;
			}
			else
			{
				MGLostSightTimeout=Level.TimeSeconds+(0.25+FRand()*0.35);
				Controller.Focus=None;
			}

			if(!bFireAtWill)
			{
				MGFireDuration=Level.TimeSeconds+(0.75+FRand()*0.5);
			}
			else if(FRand()<0.03 && Controller.Enemy!=none && PlayerController(Controller.Enemy.Controller)!=none)
			{
				PlayerController(Controller.Enemy.Controller).Speech('AUTO', 9, "");
			}

			bFireAtWill=True;
			bShotAnim=true;
			Acceleration=vect(0,0,0);

			SetAnimAction('FireMG');
			bWaitForAnim=true;
		}
	}

	function FireMGShot()
	{
		local vector Start,End,HL,HN,Dir;
		local rotator R;
		local Actor A;

		MGFireCounter--;

		if(AmbientSound!=MiniGunFireSound)
		{
			SoundVolume=255;
			SoundRadius=400;
			AmbientSound=MiniGunFireSound;
		}

		Start=GetBoneCoords('tip').Origin;
		if(Controller.Focus!=None)
			R=rotator(Controller.Focus.Location-Start);
		else R=rotator(Controller.FocalPoint-Start);
		if(NeedToTurnFor(R))
			R=Rotation;

		Dir=Normal(vector(R)+VRand()*0.03);
		End=Start+Dir*10000;

		bBlockHitPointTraces=false;
		A=Trace(HL,HN,End,Start,True);
		bBlockHitPointTraces=true;

		if(A==None)
			Return;
		TraceHitPos=HL;
		if(Level.NetMode!=NM_DedicatedServer)
			AddTraceHitFX(HL);

		if(A!=Level)
		{
			A.TakeDamage(MGDamage+Rand(3),Self,HL,Dir*500,Class'DamageType');
		}
	}

	function bool NeedToTurnFor(rotator targ)
	{
		local int YawErr;

		targ.Yaw=DesiredRotation.Yaw & 65535;
		YawErr=(targ.Yaw-(Rotation.Yaw & 65535)) & 65535;
		return !((YawErr<2000) || (YawErr>64535));
	}

Begin:
	While(True)
	{
		Acceleration=vect(0,0,0);

		if(MGLostSightTimeout>0 && Level.TimeSeconds>MGLostSightTimeout)
		{
			bShotAnim=true;
			Acceleration=vect(0,0,0);
			SetAnimAction('FireEndMG');
			HandleWaitForAnim('FireEndMG');
			GoToState('');
		}

		if(MGFireCounter<=0)
		{
			bShotAnim=true;
			Acceleration=vect(0,0,0);
			SetAnimAction('FireEndMG');
			HandleWaitForAnim('FireEndMG');
			GoToState('');
		}

		if(Level.TimeSeconds>MGFireDuration)
		{
			if(AmbientSound!=MiniGunSpinSound)
			{
				SoundVolume=185;
				SoundRadius=200;
				AmbientSound=MiniGunSpinSound;
			}
			Sleep(0.5+FRand()*0.75);
			MGFireDuration=Level.TimeSeconds+(2+FRand()*2);
		}
		else
		{
			if(bFireAtWill)
				FireMGShot();
			Sleep(0.05);
		}
	}
}

state FireMissile
{
Ignores RangedAttack;

	function bool ShouldChargeFromDamage()
	{
		return false;
	}

	function BeginState()
	{
		Acceleration=vect(0,0,0);
	}
	
	function AnimEnd(int Channel)
	{
		local vector Start;
		local Rotator R;

		Start=GetBoneCoords('tip').Origin;

		if(!SavedFireProperties.bInitialized)
		{
			SavedFireProperties.AmmoClass=MyAmmo.Class;
			SavedFireProperties.ProjectileClass=MyAmmo.ProjectileClass;
			SavedFireProperties.WarnTargetPct=0.15;
			SavedFireProperties.MaxRange=10000;
			SavedFireProperties.bTossed=False;
			SavedFireProperties.bTrySplash=False;
			SavedFireProperties.bLeadTarget=True;
			SavedFireProperties.bInstantHit=True;
			SavedFireProperties.bInitialized=true;
		}

		R=AdjustAim(SavedFireProperties,Start,100);
		PlaySound(RocketFireSound,SLOT_Interact,2.0,,TransientSoundRadius,,false);
		Spawn(Class'ID_Monster_Zombie_Patty_LAWProjectile',,,Start,R);

		bShotAnim=true;
		Acceleration=vect(0,0,0);
		SetAnimAction('FireEndMissile');
		HandleWaitForAnim('FireEndMissile');

		if(FRand()<0.05 && Controller.Enemy!=none && PlayerController(Controller.Enemy.Controller)!=none)
		{
			PlayerController(Controller.Enemy.Controller).Speech('AUTO', 10, "");
		}
		
		GoToState('');
	}
Begin:
	while (true)
	{
		Acceleration=vect(0,0,0);
		Sleep(0.1);
	}
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	if(Controller.Target!=None && Controller.Target.IsA('NetKActor'))
		pushdir=Normal(Controller.Target.Location-Location)*100000;

	return Super.MeleeDamageTarget(hitdamage, pushdir);
}

state Charging
{
	function bool CanSpeedAdjust()
	{
		return false;
	}

	function bool ShouldChargeFromDamage()
	{
		return false;
	}

	function BeginState()
	{
		bChargingPlayer=True;
		if(Level.NetMode!=NM_DedicatedServer)
			PostNetReceive();

		NumChargeAttacks=Rand(2)+1;
	}

	function EndState()
	{
		GroundSpeed=GetOriginalGroundSpeed();
		bChargingPlayer=False;
		ChargeDamage=0;
		if(Level.NetMode!=NM_DedicatedServer)
			PostNetReceive();

		LastChargeTime=Level.TimeSeconds;
	}

	function Tick(float Delta)
	{

		if(NumChargeAttacks<=0)
		{
			GoToState('');
		}

		if(Role==ROLE_Authority && bShotAnim)
		{
			if(bChargingPlayer)
			{
				bChargingPlayer=false;
				if(Level.NetMode!=NM_DedicatedServer)
					PostNetReceive();
			}
			GroundSpeed=OriginalGroundSpeed*1.25;
			if(LookTarget!=None)
			{
				Acceleration=AccelRate*Normal(LookTarget.Location-Location);
			}
		}
		else
		{
			if(!bChargingPlayer)
			{
				bChargingPlayer=true;
				if(Level.NetMode!=NM_DedicatedServer)
					PostNetReceive();
			}

			GroundSpeed=OriginalGroundSpeed*2.5;
		}


		Global.Tick(Delta);
	}

	function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
		local bool RetVal;

		NumChargeAttacks--;

		RetVal=Global.MeleeDamageTarget(hitdamage, pushdir*1.5);
		if(RetVal)
			GoToState('');
		return RetVal;
	}

	function RangedAttack(Actor A)
	{
		if(VSize(A.Location-Location)>700 && Level.TimeSeconds-LastForceChargeTime>3.0)
			GoToState('');
		Global.RangedAttack(A);
	}
Begin:
	Sleep(6);
	GoToState('');
}

function BeginHealing()
{
	MonsterController(Controller).WhatToDoNext(55);
}


state Healing
{
	function bool ShouldChargeFromDamage()
	{
		return false;
	}

Begin:
	Sleep(GetAnimDuration('Heal'));
	GoToState('');
}

state KnockDown
{
	function bool ShouldChargeFromDamage()
	{
		return false;
	}

Begin:
	if(Health>0)
	{
		Sleep(GetAnimDuration('KnockDown'));
		CloakBoss();
		PlaySound(sound'KF_EnemiesFinalSnd.Patriarch.Kev_SaveMe', SLOT_Misc, 2.0,,500.0);
		if(KFGameType(Level.Game).FinalSquadNum==SyringeCount)
		{
		  KFGameType(Level.Game).AddBossBuddySquad();
		}
		GotoState('Escaping');
	}
	else
	{
	  GotoState('');
	}
}

State Escaping extends Charging
{
	function BeginHealing()
	{
		bShotAnim=true;
		Acceleration=vect(0,0,0);
		SetAnimAction('Heal');
		HandleWaitForAnim('Heal');

		GoToState('Healing');
	}

	function RangedAttack(Actor A)
	{
		if(bShotAnim)
			return;
		else if(IsCloseEnuf(A))
		{
			if(bCloaked)
				UnCloakBoss();
			bShotAnim=true;
			Acceleration=vect(0,0,0);
			Acceleration=(A.Location-Location);
			SetAnimAction('MeleeClaw');
		}
	}

	function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
		return Global.MeleeDamageTarget(hitdamage, pushdir*1.5);
	}

	function Tick(float Delta)
	{
		if(Role==ROLE_Authority && bShotAnim)
		{
			if(bChargingPlayer)
			{
				bChargingPlayer=false;
				if(Level.NetMode!=NM_DedicatedServer)
					PostNetReceive();
			}
			GroundSpeed=GetOriginalGroundSpeed();
		}
		else
		{
			if(!bChargingPlayer)
			{
				bChargingPlayer=true;
				if(Level.NetMode!=NM_DedicatedServer)
					PostNetReceive();
			}

			GroundSpeed=OriginalGroundSpeed*2.5;
		}


		Global.Tick(Delta);
	}

	function EndState()
	{
		GroundSpeed=GetOriginalGroundSpeed();
		bChargingPlayer=False;
		if(Level.NetMode!=NM_DedicatedServer)
			PostNetReceive();
		if(bCloaked)
			UnCloakBoss();
	}

Begin:
	While(true)
	{
		Sleep(0.5);
		if(!bCloaked && !bShotAnim)
			CloakBoss();
		if(!Controller.IsInState('SyrRetreat') && !Controller.IsInState('WaitForAnim'))
			Controller.GoToState('SyrRetreat');
	}
}

State SneakAround extends Escaping
{
	function BeginHealing()
	{
		MonsterController(Controller).WhatToDoNext(56);
		GoToState('');
	}

	function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
		local bool RetVal;

		RetVal=super.MeleeDamageTarget(hitdamage, pushdir);

		GoToState('');
		return RetVal;
	}

	function BeginState()
	{
		super.BeginState();
		SneakStartTime=Level.TimeSeconds;
	}

	function EndState()
	{
		super.EndState();
		LastSneakedTime=Level.TimeSeconds;
	}


Begin:
	CloakBoss();
	While(true)
	{
		Sleep(0.5);

		if(Level.TimeSeconds-SneakStartTime>10.0)
		{
			GoToState('');
		}

		if(!bCloaked && !bShotAnim)
			CloakBoss();
		if(!Controller.IsInState('ZombieHunt') && !Controller.IsInState('WaitForAnim'))
		{
			Controller.GoToState('ZombieHunt');
		}
	}
}

State InitialSneak extends SneakAround
{
Begin:
	CloakBoss();
	While(true)
	{
		Sleep(0.5);
		SneakCount++;

		if(SneakCount>1000 || (Controller!=none && ID_Monster_Zombie_Patty_Controller(Controller).bAlreadyFoundEnemy))
		{
			GoToState('');
		}

		if(!bCloaked && !bShotAnim)
			CloakBoss();
		if(!Controller.IsInState('InitialHunting') && !Controller.IsInState('WaitForAnim'))
		{
			Controller.GoToState('InitialHunting');
		}
	}
}

simulated function DropNeedle()
{
	if(CurrentNeedle!=None)
	{
		DetachFromBone(CurrentNeedle);
		CurrentNeedle.SetLocation(GetBoneCoords('Rpalm_MedAttachment').Origin);
		CurrentNeedle.DroppedNow();
		CurrentNeedle=None;
	}
}
simulated function NotifySyringeA()
{
	if(Level.NetMode!=NM_Client)
	{
		if(SyringeCount<3)
			SyringeCount++;
		if(Level.NetMode!=NM_DedicatedServer)
			PostNetReceive();
	}
	if(Level.NetMode!=NM_DedicatedServer)
	{
		DropNeedle();
		CurrentNeedle=Spawn(Class'BossHPNeedle');
		AttachToBone(CurrentNeedle,'Rpalm_MedAttachment');
	}
}
function NotifySyringeB()
{
	if(Level.NetMode!=NM_Client)
	{
		Health+=HealingAmount;
		if(Health>HealthMax)
			Health=HealthMax;
		bHealed=true;
	}
}
simulated function NotifySyringeC()
{
	if(Level.NetMode!=NM_DedicatedServer && CurrentNeedle!=None)
	{
		CurrentNeedle.Velocity=vect(-45,300,-90)>>Rotation;
		DropNeedle();
	}
}

simulated function PostNetReceive()
{
	if(bClientMiniGunning!=bMinigunning)
	{
		bClientMiniGunning=bMinigunning;

		if(bMinigunning)
		{
			IdleHeavyAnim='FireMG';
			IdleRifleAnim='FireMG';
			IdleCrouchAnim='FireMG';
			IdleWeaponAnim='FireMG';
			IdleRestAnim='FireMG';
		}
		else
		{
			IdleHeavyAnim='BossIdle';
			IdleRifleAnim='BossIdle';
			IdleCrouchAnim='BossIdle';
			IdleWeaponAnim='BossIdle';
			IdleRestAnim='BossIdle';
		}
	}

	if(bClientCharg!=bChargingPlayer)
	{
		bClientCharg=bChargingPlayer;
		if(bChargingPlayer)
		{
			MovementAnims[0]=ChargingAnim;
			MovementAnims[1]=ChargingAnim;
			MovementAnims[2]=ChargingAnim;
			MovementAnims[3]=ChargingAnim;
		}
		else if(!bChargingPlayer)
		{
			MovementAnims[0]=default.MovementAnims[0];
			MovementAnims[1]=default.MovementAnims[1];
			MovementAnims[2]=default.MovementAnims[2];
			MovementAnims[3]=default.MovementAnims[3];
		}
	}
	else if(ClientSyrCount!=SyringeCount)
	{
		ClientSyrCount=SyringeCount;
		Switch(SyringeCount)
		{
			Case 1:
				SetBoneScale(3,0,'Syrange1');
				Break;
			Case 2:
				SetBoneScale(3,0,'Syrange1');
				SetBoneScale(4,0,'Syrange2');
				Break;
			Case 3:
				SetBoneScale(3,0,'Syrange1');
				SetBoneScale(4,0,'Syrange2');
				SetBoneScale(5,0,'Syrange3');
				Break;
			Default:
				SetBoneScale(3,1,'Syrange1');
				SetBoneScale(4,1,'Syrange2');
				SetBoneScale(5,1,'Syrange3');
				Break;
		}
	}
	else if(TraceHitPos!=vect(0,0,0))
	{
		AddTraceHitFX(TraceHitPos);
		TraceHitPos=vect(0,0,0);
	}
	else if(bClientCloaked!=bCloaked)
	{
		bClientCloaked=bCloaked;
		bCloaked=!bCloaked;
		if(bCloaked)
			UnCloakBoss();
		else CloakBoss();
		bCloaked=bClientCloaked;
	}
}

simulated function int DoAnimAction(name AnimName)
{
	if(AnimName=='MeleeImpale' || AnimName=='MeleeClaw' || AnimName=='transition'/*|| AnimName=='FireMG'*/)
	{
		AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
		PlayAnim(AnimName,, 0.1, 1);
		Return 1;
	}
	Return Super.DoAnimAction(AnimName);
}


simulated event SetAnimAction(name NewAction)
{
	local int meleeAnimIndex;

	if(NewAction=='')
		Return;
	if(NewAction=='Claw')
	{
		meleeAnimIndex=Rand(3);
		NewAction=meleeAnims[meleeAnimIndex];
		CurrentDamtype=ZombieDamType[meleeAnimIndex];
	}

	ExpectingChannel=DoAnimAction(NewAction);

	if(Controller!=none)
	{
	  ID_Monster_Zombie_Patty_Controller(Controller).AnimWaitChannel=ExpectingChannel;
	}

	if(AnimNeedsWait(NewAction))
	{
		bWaitForAnim=true;
	}
	else
	{
		bWaitForAnim=false;
	}

	if(Level.NetMode!=NM_Client)
	{
		AnimAction=NewAction;
		bResetAnimAct=True;

		ResetAnimActTime=Level.TimeSeconds+0.3;
	}
}

simulated function HandleWaitForAnim(name NewAnim)
{
	local float RageAnimDur;

	Controller.GoToState('WaitForAnim');
	RageAnimDur=GetAnimDuration(NewAnim);

	ID_Monster_Zombie_Patty_Controller(Controller).SetWaitForAnimTimout(RageAnimDur,NewAnim);
}

simulated function bool AnimNeedsWait(name TestAnim)
{
	if(/*TestAnim=='MeleeImpale' || TestAnim=='MeleeClaw' || TestAnim=='transition' ||*/TestAnim=='FireMG' ||
		TestAnim=='PreFireMG' || TestAnim=='PreFireMissile' || TestAnim=='FireEndMG'|| TestAnim=='FireEndMissile' ||
		TestAnim=='Heal' || TestAnim=='KnockDown' || TestAnim=='Entrance' || TestAnim=='VictoryLaugh')
	{
		return true;
	}

	return false;
}

simulated function HandleBumpGlass();

function bool FlipOver()
{
	Return False;
}

function bool ShouldChargeFromDamage()
{
	if((SyringeCount==0 && Health<HealingLevels[0]) || (SyringeCount==1 && Health<HealingLevels[1]) || (SyringeCount==2 && Health<HealingLevels[2]))
	{
		return false;
	}
	else if(!bChargingPlayer && Level.TimeSeconds-LastForceChargeTime>(5.0+5.0*FRand()))
	{
		return true;
	}

	return false;
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType>damageType, optional int HitIndex)
{
	local float DamagerDistSq;
	local float UsedPipeBombDamScale;

	if(class<DamTypePipeBomb>(damageType)!=none)
	{
	  UsedPipeBombDamScale=FMax(0,(1.0-PipeBombDamageScale));

	  PipeBombDamageScale+=0.075;

	  if(PipeBombDamageScale>1.0)
	  {
		  PipeBombDamageScale=1.0;
	  }

	  Damage*=UsedPipeBombDamScale;
	}

	Super.TakeDamage(Damage,instigatedBy,hitlocation,Momentum,damageType);

	if(Level.TimeSeconds-LastDamageTime>10)
	{
		ChargeDamage=0;
	}
	else
	{
		LastDamageTime=Level.TimeSeconds;
		ChargeDamage+=Damage;
	}

	if(ShouldChargeFromDamage() && ChargeDamage>200)
	{
		if(InstigatedBy!=none)
		{
			DamagerDistSq=VSizeSquared(Location-InstigatedBy.Location);

			if(DamagerDistSq<(700*700))
			{
				SetAnimAction('transition');
				ChargeDamage=0;
				LastForceChargeTime=Level.TimeSeconds;
				GoToState('Charging');
				return;
			}
		}
	}

	if(Health<=0 || SyringeCount==3 || IsInState('Escaping') || IsInState('KnockDown')/*|| bShotAnim*/)
		Return;

	if((SyringeCount==0 && Health<HealingLevels[0]) || (SyringeCount==1 && Health<HealingLevels[1]) || (SyringeCount==2 && Health<HealingLevels[2]))
	{
		bShotAnim=true;
		Acceleration=vect(0,0,0);
		SetAnimAction('KnockDown');
		HandleWaitForAnim('KnockDown');
		KFMonsterController(Controller).bUseFreezeHack=True;
		GoToState('KnockDown');
	}
}

function DoorAttack(Actor A)
{
	if(bShotAnim)
		return;
	else if(A!=None)
	{
		Controller.Target=A;
		bShotAnim=true;
		Acceleration=vect(0,0,0);
		SetAnimAction('PreFireMissile');
		HandleWaitForAnim('PreFireMissile');
		GoToState('FireMissile');
	}
}
function RemoveHead();
function PlayDirectionalHit(Vector HitLoc);

function bool SameSpeciesAs(Pawn P)
{
	return False;
}

function ClawDamageTarget()
{
	local vector PushDir;
	local name Anim;
	local float frame,rate;
	local float UsedMeleeDamage;
	local bool bDamagedSomeone;
	local KFHumanPawn P;
	local Actor OldTarget;

	if(MeleeDamage>1)
	{
		UsedMeleeDamage=(MeleeDamage-(MeleeDamage*0.05))+(MeleeDamage*(FRand()*0.1));
	}
	else
	{
		UsedMeleeDamage=MeleeDamage;
	}

	GetAnimParams(1, Anim,frame,rate);

	if(Anim=='MeleeImpale')
	{
		MeleeRange=ImpaleMeleeDamageRange;
	}
	else
	{
		MeleeRange=ClawMeleeDamageRange;
	}

	if(Controller!=none && Controller.Target!=none)
		PushDir=(damageForce*Normal(Controller.Target.Location-Location));
	else
		PushDir=damageForce*vector(Rotation);

	if(Anim=='MeleeImpale')
	{
		bDamagedSomeone=MeleeDamageTarget(UsedMeleeDamage, PushDir);
	}
	else
	{
		OldTarget=Controller.Target;

		foreach DynamicActors(class'KFHumanPawn', P)
		{
			if((P.Location-Location) dot PushDir>0.0)
			{
				Controller.Target=P;
				bDamagedSomeone=bDamagedSomeone || MeleeDamageTarget(UsedMeleeDamage, damageForce*Normal(P.Location-Location));
			}
		}

		Controller.Target=OldTarget;
	}

	MeleeRange=Default.MeleeRange;

	if(bDamagedSomeone)
	{
		if(Anim=='MeleeImpale')
		{
			PlaySound(MeleeImpaleHitSound, SLOT_Interact, 2.0);
		}
		else
		{
			PlaySound(MeleeAttackHitSound, SLOT_Interact, 2.0);
		}
	}
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{

}
/*
simulated function ProcessHitFX()
{
	local Coords boneCoords;
	local class<xEmitter>HitEffects[4];
	local int i,j;
	local float GibPerterbation;

	if((Level.NetMode==NM_DedicatedServer) || bSkeletized || (Mesh==SkeletonMesh))
	{
		SimHitFxTicker=HitFxTicker;
		return;
	}

	for(SimHitFxTicker=SimHitFxTicker; SimHitFxTicker!=HitFxTicker; SimHitFxTicker=(SimHitFxTicker+1) % ArrayCount(HitFX))
	{
		j++;
		if(j>30)
		{
			SimHitFxTicker=HitFxTicker;
			return;
		}

		if((HitFX[SimHitFxTicker].damtype==None) || (Level.bDropDetail && (Level.TimeSeconds-LastRenderTime>3) && !IsHumanControlled()))
			continue;

		if(HitFX[SimHitFxTicker].bone=='obliterate' && !class'GameInfo'.static.UseLowGore())
		{
			SpawnGibs(HitFX[SimHitFxTicker].rotDir, 1);
			bGibbed=true;
			Destroy();
			return;
		}

		boneCoords=GetBoneCoords(HitFX[SimHitFxTicker].bone);

		if(!Level.bDropDetail && !class'GameInfo'.static.NoBlood() && !bSkeletized && !class'GameInfo'.static.UseLowGore())
		{
			HitFX[SimHitFxTicker].damtype.static.GetHitEffects(HitEffects, Health);

			if(!PhysicsVolume.bWaterVolume)
			{
				for(i=0; i<ArrayCount(HitEffects); i++)
				{
					if(HitEffects[i]==None)
						continue;

					 AttachEffect(HitEffects[i], HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir);
				}
			}
		}
		if(class'GameInfo'.static.UseLowGore())
			HitFX[SimHitFxTicker].bSever=false;

		if(HitFX[SimHitFxTicker].bSever)
		{
			GibPerterbation=HitFX[SimHitFxTicker].damtype.default.GibPerterbation;

			switch(HitFX[SimHitFxTicker].bone)
			{
				case 'obliterate':
					break;

				case LeftThighBone:
					if(!bLeftLegGibbed)
					{
						SpawnSeveredGiblet(DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone));
						KFSpawnGiblet(class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250) ;
						KFSpawnGiblet(class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250) ;
						KFSpawnGiblet(class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250) ;
						bLeftLegGibbed=true;
					}
					break;

				case RightThighBone:
					if(!bRightLegGibbed)
					{
						SpawnSeveredGiblet(DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone));
						KFSpawnGiblet(class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250) ;
						KFSpawnGiblet(class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250) ;
						KFSpawnGiblet(class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250) ;
						bRightLegGibbed=true;
					}
					break;

				case LeftFArmBone:
					if(!bLeftArmGibbed)
					{
						SpawnSeveredGiblet(DetachedSpecialArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone));
						KFSpawnGiblet(class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250) ;
						KFSpawnGiblet(class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250) ;;
						bLeftArmGibbed=true;
					}
					break;

				case RightFArmBone:
					if(!bRightArmGibbed)
					{
						SpawnSeveredGiblet(DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone));
						KFSpawnGiblet(class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250) ;
						KFSpawnGiblet(class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250) ;
						bRightArmGibbed=true;
					}
					break;

				case 'head':
					if(!bHeadGibbed)
					{
						if(HitFX[SimHitFxTicker].damtype==class'DamTypeDecapitation')
						{
							DecapFX(boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false);
						}
						else if(HitFX[SimHitFxTicker].damtype==class'DamTypeMeleeDecapitation')
						{
							DecapFX(boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, true);
						}

					 	bHeadGibbed=true;
				 	}
					break;
			}


			if(HitFX[SimHitFXTicker].bone!='Spine' && HitFX[SimHitFXTicker].bone!=FireRootBone &&
				HitFX[SimHitFXTicker].bone!='head' && Health<=0)
				HideBone(HitFX[SimHitFxTicker].bone);
		}
	}
}

simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation)
{
	bGibbed=true;
	PlayDyingSound();

	if(class'GameInfo'.static.UseLowGore())
		return;

	if(ObliteratedEffectClass!=none)
		Spawn(ObliteratedEffectClass,,, Location, HitRotation);

	super.SpawnGibs(HitRotation,ChunkPerterbation);

	if(FRand()<0.1)
	{
		KFSpawnGiblet(class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500) ;
		KFSpawnGiblet(class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500) ;
		KFSpawnGiblet(class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500) ;
		KFSpawnGiblet(class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500) ;
		KFSpawnGiblet(class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500) ;

		SpawnSeveredGiblet(DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation);
		SpawnSeveredGiblet(DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation);
		SpawnSeveredGiblet(DetachedSpecialArmClass, Location, HitRotation, ChunkPerterbation, HitRotation);
		SpawnSeveredGiblet(DetachedArmClass, Location, HitRotation, ChunkPerterbation, HitRotation);
	}
	else if(FRand()<0.25)
	{
		KFSpawnGiblet(class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500) ;
		KFSpawnGiblet(class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500) ;
		KFSpawnGiblet(class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500) ;
		KFSpawnGiblet(class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500) ;

		SpawnSeveredGiblet(DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation);
		SpawnSeveredGiblet(DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation);
		if(FRand()<0.5)
		{
			KFSpawnGiblet(class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500) ;
			SpawnSeveredGiblet(DetachedArmClass, Location, HitRotation, ChunkPerterbation, HitRotation);
		}
	}
	else if(FRand()<0.35)
	{
		KFSpawnGiblet(class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500) ;
		KFSpawnGiblet(class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500) ;
		SpawnSeveredGiblet(DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation);
	}
	else if(FRand()<0.5)
	{
		KFSpawnGiblet(class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500) ;
		KFSpawnGiblet(class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500) ;
		SpawnSeveredGiblet(DetachedArmClass, Location, HitRotation, ChunkPerterbation, HitRotation);
	}
}
*/

defaultproperties
{
     CanBeKilledInstant=False
     DetachedArmClass=Class'KFChar.SeveredArmPatriarch'
     DetachedLegClass=Class'KFChar.SeveredLegPatriarch'
     DetachedHeadClass=Class'KFChar.SeveredHeadPatriarch'
     DetachedSpecialArmClass=Class'KFChar.SeveredRocketArmPatriarch'
     ControllerClass=Class'IDRPGMod.ID_Monster_Zombie_Patty_Controller'
}
