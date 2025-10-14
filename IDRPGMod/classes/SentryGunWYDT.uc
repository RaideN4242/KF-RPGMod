// Written by Marco
Class SentryGunWYDT extends ID_Weapon_Base_Turret_Sentry_Base // Gay hack, but has to be done.
	Placeable
	Config(KFSentryGunWYDT)
	CacheExempt;

//#exec obj load file="PortalTurret.ukx" package="KFSentryGunWYDT"
//#exec obj load file="XRXSentryGunDT_A.ukx" package="KFSentryGunWYDT"
#exec obj load file="KF_LAWSnd.uax"

var float HeatLevel;
var VehicleExhaustEffect PeregrevEmmiter;

var	array<HeadlightCorona>	HeadlightCorona;
var()	array<vector>	HeadlightCoronaOffset;
var()	Material	HeadlightCoronaMaterial;
var()	float			HeadlightCoronaMaxSize;

var FLProjector	FLProjector;

var()	Material	HeadlightProjectorMaterial; // If null, do not create projector.
var()	vector		HeadlightProjectorOffset;
var()	rotator		HeadlightProjectorRotation;
var()	float			HeadlightProjectorScale;


var()		class<InventoryAttachment>	TacShineClass;
var 		Actor 						TacShine;
var()	float			TacShineScale;

var transient SentryGunWYDTMuzzleFlash Flashes[4];
var transient byte BarrelNumber,FXBarrelNumber;
var transient float NextVoiceTimer;
var transient SentryGunWYDTLazor LaserFX;
var() name BarrelBones[4];

var KRigidBodyState UpdatingPosition;
var byte AnimRepNum,IdleRotPos,OldAnimRep;

var vector AttackTargetPos;
var rotator CurrentRot,RotSpeed;
var float NextKPackSt,NextFlipCheckTime;
//var() globalconfig int HitDamages,TurretHealth;
var() class<DamageType> HitDgeType;
//var() float FireRateTime;
var vector LaserOffset;
var KFNewTracer mTracer[4];
var transient Font HUDFontz[2];
//var Pawn OwnerPawn;
//var SentryGunWYDTWeap WeaponOwner;

var vector RepHitPos[2]; // Fires dual shots so rep 2 at once.

// Bitmasks
var bool bNeedsKUpdate,bIsCurrentlyFlipped;
var() bool bNoAutoDestruct,bEvilTurret,bHasGodMode;

replication
{
	// Variables the server should send to the client.
	reliable if(bNetDirty && bNetInitial && Role == Role_Authority)
		HeatLevel;
	reliable if( Role==ROLE_Authority )
		UpdatingPosition,AnimRepNum,RepHitPos/*,TurretHealth*/;
	reliable if( Role==ROLE_Authority && AnimRepNum==2 )
		AttackTargetPos;
}
/*
final function SetOwningPlayer( Pawn Other, SentryGunWYDTWeap Wep )
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
	S = "Health:"@Max(1,float(Health)/float(TurretHealth)*100.f)@"%";
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
			Case 4:
				PlayFoldTurret();	
				Break;
			Default:
				PlayTurretDied();
				Break;
		}
	}
	if( Physics==PHYS_Karma /*&& UpdatingPosition.Position!=vect(0,0,0)*/ )
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
	
	//----------------------------------------------------------------
/*	// log
	if (NextKPackSt<Level.TimeSeconds)
	{
		NextKPackSt = Level.TimeSeconds+1.f;
		Log("HeatLevel:"@HeatLevel);
		Log("AnimRepNum:"@AnimRepNum);
	}
*/
	if( AnimRepNum==0 && HeatLevel > 0 || 
	AnimRepNum==1 && HeatLevel > 0 || 
	AnimRepNum==4 && HeatLevel > 0 || 
	AnimRepNum==5 && HeatLevel > 0 )
	{
		if (HeatLevel > 0)
			HeatLevel = FMax(0, HeatLevel - Delta/20); //скорость остывания
			
		if (Level.NetMode != NM_DedicatedServer && /*SentryGunWYDTAI(Controller).IsInState('Peregrev') &&*/
		PeregrevEmmiter==None && HeatLevel>0.32)
		{
			PeregrevEmmiter = Spawn(class'HeatEm',Self);
			if ( PeregrevEmmiter != none )
			{
				AttachToBone(PeregrevEmmiter,'tip90');
				PeregrevEmmiter.SetRelativeRotation(rot(0, 32000, 0));
			}
		}
	}
	
	else if( AnimRepNum==2 && HeatLevel >= 0)
	{
		//HeatLevel = FMin(1, HeatLevel + Delta/30); //скорость нагрева 
	}
	//----------------------------------------------------------------
	
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
				bIsCurrentlyFlipped = bFlip;
				SentryGunWYDTAI(Controller).NotifyGotFlipped(bFlip);
			}
		}
	}

	if( Level.NetMode==NM_DedicatedServer || ((Level.TimeSeconds-LastRenderTime)>2 && (LaserFX==None || (Level.TimeSeconds-LaserFX.LastRenderTime)>2)) )
		return;

	OlR = CurrentRot;
	if( AnimRepNum==0 || AnimRepNum==1 || AnimRepNum==4 || AnimRepNum==5 ) // 3xzet
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
		CurrentRot.Yaw = FixedTurn(CurrentRot.Yaw,Clamp(DesR.Yaw,-65535,65535),RotationRate.Yaw*Delta);
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
		DesR.Pitch = -CurrentRot.Pitch;	
		SetBoneRotation('Head',DesR); 
		DesR.Yaw = -CurrentRot.Yaw; 
		DesR.Pitch = 0;
		SetBoneRotation('Spine',DesR); 
	}
}
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex )
{
/*	if( Level.NetMode==NM_Client || (!bEvilTurret && KFPawn(instigatedBy)!=None) )
		Return;*/
	if(Level.NetMode==NM_Client || (!bEvilTurret && KFPawn(instigatedBy)!=None && damageType != class'DamTypeWelder'))
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
		SentryGunWYDTAI(Controller).NotifyGotFlipped(true);
	}
}

simulated function PlayDeploy()
{
	AnimRepNum = 1;
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( LaserFX==None )
	{
		LaserFX = Spawn(Class'SentryGunWYDTLazor',Self);
		AttachToBone(LaserFX,'tip2');
	}
	PlayAnim('UnFold',1,0.1);
	PlaySound(Sound'XRXSentryGunDT_Snd.spawn1',SLOT_Pain,1.f,,200.f); 
	SetTimer(0,false);
}

simulated function PlayUnDeploy()
{
	AnimRepNum = 0;
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( LaserFX==None )
	{
		LaserFX = Spawn(Class'SentryGunWYDTLazor',Self);
		AttachToBone(LaserFX,'tip2');
	}
	PlayAnim('Idle',0.5,0.1);
	SetTimer(0,false);
}

simulated function PlayTurretDied()
{
	AnimRepNum = 5;
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( LaserFX!=None )
	{
		LaserFX.Kill();
		LaserFX = None;
	}
	PlayAnim('Death',0.5,0.1);
	SetTimer(0,false);
}
simulated function PlayFiringTurret()
{
	AnimRepNum = 2;
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( LaserFX==None )
	{
		LaserFX = Spawn(Class'SentryGunWYDTLazor',Self);
		AttachToBone(LaserFX,'tip2');
	}
	LoopAnim('Fire',1.5,0.f);
	SetTimer(FireRateTime,true);
	Timer();
}
simulated function PlayIdleTurret()
{
	AnimRepNum = 3;
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( LaserFX==None )
	{
		LaserFX = Spawn(Class'SentryGunWYDTLazor',Self);
		AttachToBone(LaserFX,'tip2');
	}
	LoopAnim('Idle',0.8f);
	SetTimer(0,false);
}

simulated function PlayFoldTurret()
{
	AnimRepNum = 4;
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( LaserFX==None )
	{
		LaserFX = Spawn(Class'SentryGunWYDTLazor',Self);
		AttachToBone(LaserFX,'tip2');
	}
	LoopAnim('Fold',0.8f);
	SetTimer(0,false);
}


function FireAShot( vector TPos, optional vector TPosB )
{
	local vector Start,HL,HN,X,Dir;
	local Actor HitA,Res;
	local byte i;

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

		foreach TraceActors(Class'Actor',Res,HL,HN,Start+X*8000.f,Start)
		{
			if( Res!=Self && (Res==Level || Res.bBlockActors || Res.bProjTarget || Res.bWorldGeometry) && (KFPawn(Res)==None || bEvilTurret)
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
		if( HitA!=None )
		{
			if( OwnerPawn!=None )
			{
				// Give kill credit to owner but tell AI it was I who inflicted it.
				HitA.TakeDamage(HitDamages, OwnerPawn, HL, 10000*X, HitDgeType);
				if( Pawn(HitA)!=None && Pawn(HitA).Controller!=None )
					Pawn(HitA).Controller.damageAttitudeTo(Self,HitDamages);
			}
			else
			{
				Controller.bIsPlayer = False;
				HitA.TakeDamage(HitDamages, Self, HL, 10000*X, HitDgeType);
				Controller.bIsPlayer = True;
			}
		}
	}
}
simulated function Timer()
{
	// Make noise
	PlaySound(Sound'XRXSentryGunDT_Snd.Fire2',SLOT_Pain,2.f,,800.f);

	// Muzzle flash
	if( (Level.TimeSeconds-LastRenderTime)<4 )
	{
		if( Flashes[FXBarrelNumber]==None )
		{
			Flashes[FXBarrelNumber] = Spawn(Class'SentryGunWYDTMuzzleFlash');
			AttachToBone(Flashes[FXBarrelNumber],BarrelBones[FXBarrelNumber]);
			Flashes[FXBarrelNumber+1] = Spawn(Class'SentryGunWYDTMuzzleFlash');
			AttachToBone(Flashes[FXBarrelNumber+1],BarrelBones[FXBarrelNumber+1]);
		}
		else
		{
			Flashes[FXBarrelNumber].FireFX();
			Flashes[FXBarrelNumber+1].FireFX();
		}
	}
	FXBarrelNumber+=2;
	if( FXBarrelNumber>=ArrayCount(BarrelBones) )
		FXBarrelNumber = 0;
}
simulated final function ProcessHitFXs( Actor HitA, vector HitPos, vector HitNor )
{
	local float hitDist;
	local vector SpawnDir,SpawnVel,SpawnLoc;

	// Hit impact FX
	if( HitA!=None && (Pawn(HitA)==None || Vehicle(HitA)!=None) && ExtendedZCollision(HitA)==None )
		Spawn(class'ROBulletHitEffect',,, HitPos, Rotator(-HitNor));

	// Add tracert.
	if( mTracer[BarrelNumber]==None )
		mTracer[BarrelNumber] = Spawn(Class'KFNewTracer');
	if( mTracer[BarrelNumber]!=None )
	{
		SpawnLoc = GetBoneCoords(BarrelBones[BarrelNumber]).Origin;
		mTracer[BarrelNumber].SetLocation(SpawnLoc);

		hitDist = VSize(HitPos - SpawnLoc) - 50.f;

		SpawnDir = Normal(HitPos - SpawnLoc);

		if( hitDist > 100.f )
		{
			SpawnVel = SpawnDir * 7500.f;
			mTracer[BarrelNumber].Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
			mTracer[BarrelNumber].Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
			mTracer[BarrelNumber].Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
			mTracer[BarrelNumber].Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
			mTracer[BarrelNumber].Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
			mTracer[BarrelNumber].Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;

			mTracer[BarrelNumber].Emitters[0].LifetimeRange.Min = hitDist / 7500.f;
			mTracer[BarrelNumber].Emitters[0].LifetimeRange.Max = mTracer[BarrelNumber].Emitters[0].LifetimeRange.Min;

			mTracer[BarrelNumber].SpawnParticle(1);
		}
	}

	// Next barrel.
	if( ++BarrelNumber==ArrayCount(BarrelBones) )
		BarrelNumber = 0;
}
simulated function Destroyed()
{
	local byte i;

	for( i=0; i<4; ++i )
	{
		if( mTracer[i]!=None )
			mTracer[i].Destroy();
		if( Flashes[i]!=None )
			Flashes[i].Destroy();
	}
	if( LaserFX!=None )
		LaserFX.Destroy();
		
	if( PeregrevEmmiter!=None )
		PeregrevEmmiter.Destroy();
	for(i=0;i<HeadlightCorona.Length;i++)
		HeadlightCorona[i].Destroy();
		HeadlightCorona.Length = 0;

		if(FLProjector != None)
		{
			//FLProjector.bHasLight=!FLProjector.bHasLight;
			FLProjector.Destroy();
		}
		if ( TacShine != None )
			TacShine.Destroy();
	
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
	if( KFPawn(P)!=None )
		return !bEvilTurret;
	Return (Monster(P)==None);
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
			PlayerController(OwnerPawn.Controller).ReceiveLocalizedMessage(Class'SentryGunWYDTMessage',2);
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
	PlaySound(Sound'Rocket_Explode',SLOT_Pain,2.5f,,800.f);

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
		TweenAnim('Fold',0.001f);
		LaserFX = Spawn(Class'SentryGunWYDTLazor',Self);
		AttachToBone(LaserFX,'tip2');
	}

	Health = TurretHealth;
	Super.PreBeginPlay();
}

function KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	//if( SentryGunWYDT(other)!=None && VSizeSquared(Velocity)>VSizeSquared(other.Velocity) )
		//Speak(1);
}

simulated function HeadlightON()
{
	local int i;
//	Skins[0] = Shader'DZResPack.SentryGunWY_DT_sh_flash';
	if(Level.NetMode != NM_DedicatedServer && Level.bUseHeadlights && !(Level.bDropDetail || (Level.DetailMode == DM_Low)))
		{
			HeadlightCorona.Length = HeadlightCoronaOffset.Length;

			for(i=0; i<HeadlightCoronaOffset.Length; i++)
			{
				HeadlightCorona[i] = spawn( class'HeadlightCorona', self,, Location + (HeadlightCoronaOffset[i] >> Rotation) );
				HeadlightCorona[i].SetBase(self);
				HeadlightCorona[i].SetRelativeRotation(rot(0,0,0));
				HeadlightCorona[i].Skins[0] = HeadlightCoronaMaterial;
				HeadlightCorona[i].ChangeTeamTint(Team);
				HeadlightCorona[i].MaxCoronaSize = HeadlightCoronaMaxSize * Level.HeadlightScaling;
				AttachToBone(HeadlightCorona[i],'LightBone');
			}

			if(HeadlightProjectorMaterial != None)
			{
				FLProjector = spawn( class'FLProjector', self,, Location + (HeadlightProjectorOffset >> Rotation) );
				FLProjector.SetBase(self);
				FLProjector.SetRelativeRotation( HeadlightProjectorRotation );
				FLProjector.ProjTexture = HeadlightProjectorMaterial;
				FLProjector.SetDrawScale(HeadlightProjectorScale);
				FLProjector.CullDistance	= ShadowCullDistance;
				AttachToBone(FLProjector,'LightBone');
				//FLProjector.bHasLight=!FLProjector.bHasLight;
				//FLProjector.bHasLight=True;
			}
		}
	
	if ( TacShine==none )
		{
			TacShine = Spawn(TacShineClass,,,,);
			TacShine.SetDrawScale(TacShineScale);
			AttachToBone(TacShine,'LightBone');
		}
}

defaultproperties
{
     HeadlightCoronaMaterial=Texture'KillingFloorWeapons.Dualies.FlashLightCorona3P'
     HeadlightCoronaMaxSize=40.000000
     HeadlightProjectorMaterial=Texture'KillingFloorWeapons.Dualies.LightCircle'
     HeadlightProjectorOffset=(X=-2.500000,Z=75.000000)
     HeadlightProjectorRotation=(Pitch=-1000)
     HeadlightProjectorScale=0.400000
     TacShineClass=Class'KFMod.TacLightShineAttachment'
     TacShineScale=0.250000
     BarrelBones(0)="tip90"
     BarrelBones(1)="tip90"
     BarrelBones(2)="tip90"
     BarrelBones(3)="tip90"
     HitDgeType=Class'IDRPGMod.DamTypeSentryGunWYDT'
     HitDamages=18830
     TurretHealth=25000000
     FireRateTime=0.10000
     VehicleMass=500.350006
     Team=250
     VehicleNameString="Wey-Y Turret"
     bCanBeBaseForPawns=False
     PeripheralVision=-1.000000
     HealthMax=15000000.000000
     Health=15000000
     MenuName="Wey-Y Turret"
     ControllerClass=Class'IDRPGMod.SentryGunWYDTAI'
     bStasis=False
     Mesh=SkeletalMesh'DZResPack.SentryGunWYDT_Mesh'
     Skins(0)=Shader'DZResPack.SentryGunDTWY_T.SentryGunWY_DT_sh'
     SoundRadius=80.000000
     CollisionRadius=23.000000
     CollisionHeight=30.000000
     RotationRate=(Pitch=25000,Yaw=25000)
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull0
         KInertiaTensor(0)=500.209991
         KInertiaTensor(3)=500.209991
         KInertiaTensor(5)=500.209991
         KCOMOffset=(Y=-0.020000,Z=-5.000000)
         KMass=2.350000
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
         KImpactThreshold=5000000.000000
     End Object
     KParams=KarmaParamsRBFull'IDRPGMod.SentryGunWYDT.KarmaParamsRBFull0'

}
