// Written by Marco
Class PortalTurretM extends ID_Weapon_Base_Turret_Sentry_Base // Gay hack, but has to be done.
	Placeable
	Config(KFPortalTurretM)
	CacheExempt;

//var transient HealingFX Flashes[4];
//var transient byte BarrelNumber,FXBarrelNumber;
var transient float NextVoiceTimer;
var transient TurretLazorM LaserFX;
//var() name BarrelBones[4];

var KRigidBodyState UpdatingPosition;
var byte AnimRepNum,IdleRotPos,OldAnimRep;
var(Sounds) Sound AlarmNoiseSnd,DiedSnd,LockedOnSnd;
var(Sounds) sound Voices[8];
var vector AttackTargetPos;
var rotator CurrentRot,RotSpeed;
var float NextKPackSt,NextFlipCheckTime;
var() globalconfig int /*HitDamages,TurretHealth,*/ Cash;
var() class<DamageType> HitDgeType;
//var() globalconfig float FireRateTime;

var vector LaserOffset;
//var KFNewTracer mTracer[4];
var transient Font HUDFontz[2];
//var Pawn OwnerPawn;
//var PTurretM WeaponOwner;

var sound FireSound;

var vector RepHitPos[2]; // Fires dual shots so rep 2 at once.

// Bitmasks
var bool bNeedsKUpdate,bIsCurrentlyFlipped;
var() bool bNoAutoDestruct,bEvilTurret,bHasGodMode;

//var int EffectiveRange;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		UpdatingPosition,AnimRepNum,RepHitPos/*,TurretHealth*/;
	reliable if( Role==ROLE_Authority && AnimRepNum==2 )
		AttackTargetPos;
}
/*
final function SetOwningPlayer( Pawn Other, PTurretM Wep )
{
	OwnerPawn = Other;
	PlayerReplicationInfo = Other.PlayerReplicationInfo;
	WeaponOwner = Wep;
	bScriptPostRender = true;
}*/
simulated function PostRender2D(Canvas C, float ScreenLocX, float ScreenLocY)
{
	local string S;
	local float XL,YL;
	local vector D;

	if( Health<=0 || PlayerReplicationInfo==None )
		return; // Dead or unknown owner.
	D = C.Viewport.Actor.CalcViewLocation-Location;
	if( (vector(C.Viewport.Actor.CalcViewRotation) Dot D)>0 )
		return; // Behind the camera
	XL = VSizeSquared(D);
	if( XL>1440000.f || !FastTrace(C.Viewport.Actor.CalcViewLocation,Location) )
		return; // Beyond 1200 distance or not in line of sight.

	if( C.Viewport.Actor.PlayerReplicationInfo==PlayerReplicationInfo )
		C.SetDrawColor(0,200,0,255);
	else C.SetDrawColor(200,0,0,255);

	// Load up fonts if not yet loaded.
	if( Default.HUDFontz[0]==None )
	{
		Default.HUDFontz[0] = Font(DynamicLoadObject("ROFonts_Rus.ROArial7",Class'Font'));
		if( Default.HUDFontz[0]==None )
			Default.HUDFontz[0] = Font'Engine.DefaultFont';
		Default.HUDFontz[1] = Font(DynamicLoadObject("ROFonts_Rus.ROBtsrmVr12",Class'Font'));
		if( Default.HUDFontz[1]==None )
			Default.HUDFontz[1] = Font'Engine.DefaultFont';
	}
	if( C.ClipY<1024 )
		C.Font = Default.HUDFontz[0];
	else C.Font = Default.HUDFontz[1];

	C.Style = ERenderStyle.STY_Alpha;
	S = "Owner:"@PlayerReplicationInfo.PlayerName;
	C.TextSize(S,XL,YL);
	C.SetPos(ScreenLocX-XL*0.5,ScreenLocY-YL*2.f);
	C.DrawTextClipped(S,false);
	S = "Health:"@Health;
	C.TextSize(S,XL,YL);
	C.SetPos(ScreenLocX-XL*0.5,ScreenLocY-YL*0.75f);
	C.DrawTextClipped(S,false);
}
event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry || Other.bBlocksTeleport )
		return true;
	if ( Pawn(Other) != None )
		return true;
	return false;
}
//function UsedBy( Pawn user );
function bool TryToDrive(Pawn P)
{
	Return False;
}
simulated function PostNetReceive()
{
	bScriptPostRender = (PlayerReplicationInfo!=None);
	if( OldAnimRep!=AnimRepNum )
	{
		OldAnimRep = AnimRepNum;
		Switch( AnimRepNum )
		{
			Case 0:
				PlayUnDeploy();
				Break;
			Case 1:
				PlayDeploy();
				Break;
			Case 2:
				PlayFiringTurret();
				Break;
			Case 3:
				PlayIdleTurret();
				Break;
			Default:
				PlayTurretDied();
				Break;
		}
	}
	if( Physics==PHYS_Karma )
	{
		if( !KIsAwake() )
			KWake();
		bNeedsKUpdate = True;
	}
	if( RepHitPos[0]!=vect(0,0,0) )
	{
		ClientTraceHit(RepHitPos[0]);
		RepHitPos[0] = vect(0,0,0);
	}
	if( RepHitPos[1]!=vect(0,0,0) )
	{
		ClientTraceHit(RepHitPos[1]);
		RepHitPos[1] = vect(0,0,0);
	}
}
simulated final function ClientTraceHit( vector Spot )
{
	local vector Start,HL,HN,Dir;
	local Actor A;

	Start = Location+(vect(0,0,0.9)*CollisionHeight >> Rotation);
	Dir = Normal(Spot-Start);
	A = Trace(HL,HN,Spot+Dir*30.f,Spot-Dir*20.f,true);
	if( A==None )
		HL = Spot;
	ProcessHitFXs(A,HL,HN);
}
final function PackState()
{
	KGetRigidBodyState(UpdatingPosition);
}
simulated event bool KUpdateState(out KRigidBodyState newState)
{
	if( !bNeedsKUpdate )
		Return False;
	newState = UpdatingPosition;
	bNeedsKUpdate = False;
	Return True;
}
simulated final function rotator GetActualDirection()
{
	local vector X,Y,Z;

	GetAxes(CurrentRot,X,Y,Z);
	X = X>>Rotation;
	Y = Y>>Rotation;
	Z = Z>>Rotation;
	return OrthoRotation(X,Y,Z);
}
simulated final function int FixedTurn( int current, int desired, int deltaRate )
{
	current = current & 65535;

	if( deltaRate==0 )
		return current;
	desired = desired & 65535;
	if( current==desired )
		return current;
	if (current > desired)
	{
		if (current - desired < 32768)
			current -= Min((current - desired), deltaRate);
		else
			current += Min((desired + 65536 - current), deltaRate);
	}
	else if (desired - current < 32768)
		current += Min((desired - current), deltaRate);
	else current -= Min((current + 65536 - desired), deltaRate);
	return (current & 65535);
}
simulated function Tick( float Delta )
{
	local rotator OlR,DesR;
	local bool bFlip;

	if( Level.NetMode!=NM_Client && Physics==PHYS_Karma )
	{
		if( Level.NetMode!=NM_StandAlone && NextKPackSt<Level.TimeSeconds )
		{
			NextKPackSt = Level.TimeSeconds+1.f/NetUpdateFrequency;
			PackState();
		}
		if( KParams!=None && KParams.bContactingLevel && NextFlipCheckTime<Level.TimeSeconds )
		{
			NextFlipCheckTime = Level.TimeSeconds+0.6;
			bFlip = IsFlipped();
			if( bFlip!=bIsCurrentlyFlipped )
			{
				if( bFlip )
					Speak(7);
				bIsCurrentlyFlipped = bFlip;
				TurretAIM(Controller).NotifyGotFlipped(bFlip);
			}
		}
	}
	if( Level.NetMode==NM_DedicatedServer || ((Level.TimeSeconds-LastRenderTime)>2 && (LaserFX==None || (Level.TimeSeconds-LaserFX.LastRenderTime)>2)) )
		return;
	OlR = CurrentRot;
	if( AnimRepNum==0 || AnimRepNum==1 || AnimRepNum==4 )
	{
		if( CurrentRot!=rot(0,0,0) )
		{
			CurrentRot.Yaw = FixedTurn(CurrentRot.Yaw,0,RotationRate.Yaw*Delta);
			CurrentRot.Pitch = FixedTurn(CurrentRot.Pitch,0,RotationRate.Pitch*Delta);
		}
	}
	else if( AnimRepNum==2 )
	{
		DesR = Normalize(rotator((AttackTargetPos-Location) << Rotation));
		CurrentRot.Yaw = FixedTurn(CurrentRot.Yaw,Clamp(DesR.Yaw,-9000,9000),RotationRate.Yaw*Delta);
		CurrentRot.Pitch = FixedTurn(CurrentRot.Pitch,Clamp(DesR.Pitch,-7000,7000),RotationRate.Pitch*Delta);
		RotSpeed = rot(0,0,0);
	}
	else if( AnimRepNum==3 )
	{
		if( IdleRotPos==0 )
		{
			if( CurrentRot.Yaw<4000 && CurrentRot.Pitch>-5000 )
			{
				RotSpeed.Yaw+=6000*Delta;
				RotSpeed.Pitch-=6000*Delta;
			}
			else IdleRotPos = 1;
		}
		else if( IdleRotPos==1 )
		{
			if( CurrentRot.Pitch<5000 )
				RotSpeed.Pitch+=6000*Delta;
			else IdleRotPos = 2;
		}
		else if( IdleRotPos==2 )
		{
			if( CurrentRot.Yaw>-4000 && CurrentRot.Pitch>-5000 )
			{
				RotSpeed.Yaw-=6000*Delta;
				RotSpeed.Pitch-=6000*Delta;
			}
			else IdleRotPos = 3;
		}
		else
		{
			if( CurrentRot.Pitch<5000 )
				RotSpeed.Pitch+=6000*Delta;
			else IdleRotPos = 0;
		}
		CurrentRot.Yaw+=Delta*RotSpeed.Yaw;
		CurrentRot.Pitch+=Delta*RotSpeed.Pitch;
		if( CurrentRot.Yaw>4000 )
		{
			RotSpeed.Yaw = 0;
			CurrentRot.Yaw = 4000;
		}
		else if( CurrentRot.Yaw<-4000 )
		{
			RotSpeed.Yaw = 0;
			CurrentRot.Yaw = -4000;
		}
		if( CurrentRot.Pitch>5000 )
		{
			RotSpeed.Pitch = 0;
			CurrentRot.Pitch = 5000;
		}
		else if( CurrentRot.Pitch<-5000 )
		{
			RotSpeed.Pitch = 0;
			CurrentRot.Pitch = -5000;
		}
	}
	if( OlR!=CurrentRot )
	{
		DesR.Yaw = 0;
		DesR.Roll = 0;
		DesR.Pitch = -CurrentRot.Yaw;
		SetBoneRotation('Aim_LR',DesR);
		DesR.Roll = CurrentRot.Pitch;
		DesR.Pitch = 0;
		SetBoneRotation('Aim_UD',DesR);
	}
}
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex )
{
	if( Level.NetMode==NM_Client || (!bEvilTurret && KFPawn(instigatedBy)!=None) )
		Return;
		
	if (damageType == class'DamTypeWelder')
	{
		if(bIsCurrentlyFlipped)
		{
			return;
		}
		Health += Damage / 10;
		if (Health > default.TurretHealth)
			Health = default.TurretHealth;
		return;
	}
		
	if( !KIsAwake() )
		KWake();
	if( VSize(hitlocation-Location)<10 )
		hitlocation.Z+=10;
	if( damageType==HitDgeType && !bIsCurrentlyFlipped )
		Speak(3);
	if( (damageType!=None && damageType.Default.bBulletHit) || !bEvilTurret )
		momentum*=0.07f; // Reduce momentum for bullet hits.

	if( Physics==PHYS_Karma )
		KAddImpulse(momentum, hitlocation);

	if( bHasGodMode || bIsCurrentlyFlipped || damageType==HitDgeType )
		return;
	Health-=Damage;
	if( Health<=0 )
	{
		bIsCurrentlyFlipped = true;
		TurretAIM(Controller).NotifyGotFlipped(true);
	}
}
simulated function PlayDeploy()
{
	AnimRepNum = 1;
	Speak(0);
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( LaserFX==None )
		LaserFX = Spawn(Class'TurretLazorM',Self);
	PlayAnim('Deploy',0.5,0.1);
	Skins[0] = Default.Skins[0];
	SetTimer(0,false);
}
simulated function PlayUnDeploy()
{
	AnimRepNum = 0;
	Speak(6);
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( LaserFX==None )
		LaserFX = Spawn(Class'TurretLazorM',Self);
	PlayAnim('Retract',0.5,0.1);
	Skins[0] = Default.Skins[0];
	SetTimer(0,false);
}
simulated function PlayTurretDied()
{
	AnimRepNum = 4;
	Speak(2);
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( LaserFX!=None )
	{
		LaserFX.Kill();
		LaserFX = None;
	}
	PlayAnim('Retract',0.5,0.1);
	PlaySound(DiedSnd,SLOT_Pain,2.f,,400.f);
//	Skins[0] = Combiner'DZResPack.JTurretB';
	SetTimer(0,false);
}
simulated function PlayFiringTurret()
{
	AnimRepNum = 2;
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( LaserFX==None )
		LaserFX = Spawn(Class'TurretLazorM',Self);
	PlayAnim('Fire',1.5,0.f);
	//LoopAnim('Fire',1.5,0.f);
	PlaySound(LockedOnSnd,SLOT_Misc,2.f,,400.f);
	SetTimer(FireRateTime,true);
	//Timer();
}
simulated function PlayIdleTurret()
{
	AnimRepNum = 3;
	Speak(5);
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( LaserFX==None )
		LaserFX = Spawn(Class'TurretLazorM',Self);
	LoopAnim('IdleAlert',0.8f);
	Skins[0] = Default.Skins[0];
	SetTimer(0,false);
}

function FireAShot( vector TPos, optional vector TPosB )
{
	local vector Start,HL,HN,X,Dir;
	local Actor HitA,Res;
	local byte i;
	local int MedicReward;

	AttackTargetPos = TPos;
	Start = Location+(vect(0,0,0.9)*CollisionHeight >> Rotation);

	// Knock slightly back
	Dir = Normal(TPos-Start);
	if( bIsCurrentlyFlipped && Physics==PHYS_Karma )
	{
		if( !KIsAwake() )
			KWake();
		KAddImpulse(-Dir*1400,Start);
	}

	for( i=0; i<2; ++i )
	{
		if( i==1 && TPosB!=vect(0,0,0) )
			Dir = Normal(TPosB-Start);
		X = Normal(Dir+VRand()*0.03);
		if( !KIsAwake() )
			KWake();
		TPos = Start+X*10000;

		foreach TraceActors(Class'Actor',Res,HL,HN,Start+X * EffectiveRange,Start)
		{
			if( Res!=Self && (Res==Level || Res.bBlockActors || Res.bProjTarget || Res.bWorldGeometry) && (KFPawn(Res)!=None)
				&& KFBulletWhipAttachment(Res)==None )
			{
				HitA = Res;
				break;
			}
		}
		if( HitA==None )
			HL = TPos;

		if( Level.NetMode!=NM_DedicatedServer )
			ProcessHitFXs(HitA,HL,HN);

		if( Level.NetMode!=NM_StandAlone )
		{
			if( VSizeSquared(RepHitPos[i]-HL)<5.f )
				RepHitPos[i]+=VRand()*1.25f;
			else RepHitPos[i] = HL;
		}
		if( KFHumanPawn(HitA)!=None)
		{
			MedicReward = HitDamages * (1.0 + class'ID_Skill_Doctor'.static.GetHealPotencyMulti(ID_RPG_Base_HumanPawn(OwnerPawn)));
			
			if((KFHumanPawn(HitA).HealthMax-KFHumanPawn(HitA).Health)<MedicReward)
				MedicReward = KFHumanPawn(HitA).HealthMax-KFHumanPawn(HitA).Health;
				
			// Give kill credit to owner but tell AI it was I who inflicted it.
			KFHumanPawn(HitA).GiveHealth(MedicReward, KFHumanPawn(HitA).HealthMax);			
			ID_RPG_Base_PlayerController(OwnerPawn.Controller).GetStats().AddExperience(string(MedicReward));
			ID_RPG_Base_PlayerController(OwnerPawn.Controller).AddExperienceGainedMessage(string(MedicReward), OwnerPawn.Location);
			KFPlayerReplicationInfo(OwnerPawn.PlayerReplicationInfo).Score+=MedicReward;
			KFPlayerReplicationInfo(OwnerPawn.PlayerReplicationInfo).ThreeSecondScore+=MedicReward;
			KFPlayerReplicationInfo(OwnerPawn.PlayerReplicationInfo).Team.Score+=MedicReward;
			ID_RPG_Base_PlayerController(OwnerPawn.Controller).AddCashGainedMessage(MedicReward, OwnerPawn.Location);
		}
	}
}
simulated function Timer()
{
	// Make noise
	PlaySound(FireSound,SLOT_Pain,2.f,,800.f);
}
simulated final function ProcessHitFXs( Actor HitA, vector HitPos, vector HitNor )
{
	if( HitA!=None && (Pawn(HitA)==None || Vehicle(HitA)!=None) && ExtendedZCollision(HitA)==None )
		Spawn(class'ROBulletHitEffect',,, HitPos, Rotator(-HitNor));
}
simulated function Destroyed()
{
	if( LaserFX!=None )
		LaserFX.Destroy();
	if( Controller!=None )
		Controller.Destroy();
	if( Driver!=None )
		Driver.Destroy();
	Super.Destroyed();
}
event PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( (ControllerClass != None) && (Controller == None) )
		Controller = spawn(ControllerClass);
	if ( Controller != None )
		Controller.Possess(self);
}
simulated function bool IsFlipped()
{
	local vector worldUp, gravUp;

	gravUp = -Normal(PhysicsVolume.Gravity);
	if( gravUp==vect(0,0,0) )
		gravUp.Z = -1;
	worldUp = vect(0,0,1) >> Rotation;
	if( worldUp Dot gravUp<0.75f )
		return true;

	return false;
}
function bool SameSpeciesAs(Pawn P)
{
	if( KFHumanPawn(P)==None )
		return true;
	else
		Return false;
}
simulated function PostNetBeginPlay()
{
	RepHitPos[0] = vect(0,0,0);
	RepHitPos[1] = vect(0,0,0);
	bNetNotify = True;
	PostNetReceive();
}
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( bDeleteMe || Level.bLevelChange || Level.Game == None )
		return; // already destroyed, or level is being cleaned up

	if( WeaponOwner!=None )
	{
		if( OwnerPawn!=None && PlayerController(OwnerPawn.Controller)!=None )
			PlayerController(OwnerPawn.Controller).ReceiveLocalizedMessage(Class'TurretMessageM',2);
		WeaponOwner.CurrentSentry = None;
		if(OwnerPawn!=None && ID_RPG_Base_HumanPawn(OwnerPawn)!=None)
			ID_RPG_Base_HumanPawn(OwnerPawn).HasTurret--;
		WeaponOwner.Destroy();
		WeaponOwner = None;
	}
	if ( Controller != None )
	{
		Controller.bIsPlayer = False;
		Level.Game.Killed(Killer, Controller, self, damageType);
		Controller.Destroy();
	}

	TriggerEvent(Event, self, None);

	// remove powerup effects, etc.
	RemovePowerups();
	Spawn(Class'PanzerfaustHitConcrete_simple');
	PlaySound(Sound'KF_GrenadeSnd.NadeBase.Nade_Explode1',SLOT_Pain,2.5f,,800.f);

	Destroy();
}
simulated function int GetTeamNum()
{
	Return 250;
}
simulated event SetInitialState()
{
	Super(Actor).SetInitialState();
}
simulated event DrivingStatusChanged();
event TakeWaterDamage(float DeltaTime);
simulated function PreBeginPlay()
{
	if( KarmaParamsRBFull(KParams)!=None )
		KarmaParamsRBFull(KParams).bHighDetailOnly = False; // Hack to fix some issues.
	if( Level.NetMode!=NM_DedicatedServer )
	{
		TweenAnim('Idle',0.001f);
		if(LaserFX==None)
			LaserFX = Spawn(Class'TurretLazorM',Self);
	}
	Health = TurretHealth;
	HealthMax = TurretHealth;
	Super.PreBeginPlay();
}

final function Speak( byte Num )
{
	if( NextVoiceTimer<Level.TimeSeconds )
	{
		PlaySound(Voices[Num],SLOT_Talk,2.f,,500.f);
		NextVoiceTimer = Level.TimeSeconds+1.f+FRand();
	}
}

function KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	if( PortalTurretM(other)!=None && VSizeSquared(Velocity)>VSizeSquared(other.Velocity) )
		Speak(1);
}

defaultproperties
{
     AlarmNoiseSnd=Sound'DZResPack.Base.Talert'
     DiedSnd=Sound'DZResPack.Base.Tdie'
     LockedOnSnd=Sound'DZResPack.Base.Tactive'
     Voices(0)=SoundGroup'DZResPack.Speech.GTurretActivate'
     Voices(1)=SoundGroup'DZResPack.Speech.GTurretCollide'
     Voices(2)=SoundGroup'DZResPack.Speech.GTurretDisabled'
     Voices(3)=SoundGroup'DZResPack.Speech.GTurretFF'
     Voices(4)=SoundGroup'DZResPack.Speech.GTurretPickup'
     Voices(5)=SoundGroup'DZResPack.Speech.GTurretSearching'
     Voices(6)=SoundGroup'DZResPack.Speech.GTurretSleep'
     Voices(7)=SoundGroup'DZResPack.Speech.GTurretTipped'
     HitDgeType=Class'KFMod.KFProjectileWeaponDamageType'
     LaserOffset=(X=12.000000,Z=11.800000)
     FireSound=SoundGroup'KF_MP7Snd.Medicgun_Fire'
     HitDamages=5
     TurretHealth=400
     EffectiveRange=4000
     FireRateTime=0.070000
     VehicleMass=0.350000
     Team=250
     VehicleNameString="Turret"
     bCanBeBaseForPawns=False
     PeripheralVision=0.700000
     Health=400
     MenuName="Turret"
     ControllerClass=Class'IDRPGMod.TurretAIM'
     bStasis=False
     Mesh=SkeletalMesh'DZResPack.TurretMesh'
     Skins(0)=Combiner'DZResPack.Skins.JTurretA'
     SoundRadius=140.000000
     CollisionRadius=23.000000
     CollisionHeight=28.000000
     RotationRate=(Pitch=25000,Yaw=25000)
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull0
         KInertiaTensor(0)=0.100000
         KInertiaTensor(3)=0.100000
         KInertiaTensor(5)=0.100000
         KCOMOffset=(Y=-0.020000)
         KMass=0.350000
         KAngularDamping=0.010000
         KBuoyancy=1.100000
         KStartEnabled=True
         KActorGravScale=2.000000
         KMaxSpeed=1000.000000
         KMaxAngularSpeed=30.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.850000
         KImpactThreshold=45.000000
     End Object
     KParams=KarmaParamsRBFull'IDRPGMod.PortalTurretM.KarmaParamsRBFull0'

}
