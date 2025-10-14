// Base Zombie Class.
class ID_RPG_Base_Monster extends KFMonster
	Abstract;

var string ExperiencePoints;
var int Lvl;
var bool IsBoss;
var float HealthPerLvl;
var float HealthPerPlayer;
var float SpeedPerLvl;
var float DmgPerLvl;
var bool CanBeKilledInstant;

var int ChanceToBeBoss;
var int BossHpMultiplier;
var bool IsSizeChanged;
var int DamageForPeriodOfTime;
var float PeriodForDamage;

var int ShockDur;
var bool bIsDied;
var float LastCheckTime_bIsDied;
var bool bZedsPause,bFullFreeze;
var float TruePMHeadHeight;

replication
{
	reliable if(Role==ROLE_Authority)
		Lvl, IsBoss;

	reliable if(bNetDirty && Role==ROLE_Authority)
		bIsDied, LastCheckTime_bIsDied;
}

function string MultiplyNumericValuesFromStrings(string S, string SS)
{
	return class'USB_Commands'.static.MultiplyNumericValuesFromStrings(S,SS);
}

function string DivideNumericValuesFromStrings(string S, string SS)
{
	return class'USB_Commands'.static.DivideNumericValuesFromStrings(S,SS);
}

function int GetNumericValueFromString(string S)
{
	return class'USB_Commands'.static.GetNumericValueFromString(S);
}

function SetShocked(float ZapAmount, Pawn Instigator)
{
	LastZapTime=Level.TimeSeconds;

	if(bZapped)
	{
		TotalZap=ZapThreshold;
		RemainingZap=ShockDur;
		SetOverlayMaterial(Material'DZResPack.energy_sh', RemainingZap, true);
	}
	else
	{
		TotalZap+=ZapAmount;
		RemainingZap=ShockDur;
		SetOverlayMaterial(Material'DZResPack.energy_sh', RemainingZap, true);
		bZapped=true; 
	}
	ZappedBy=Instigator;
}
/*
function SetNeted(float ZapAmount, Pawn Instigator)
{
	SetOverlayMaterial(Material'DZResPack.NetOV_sh', ZapAmount, true);
}
*/
function Died(Controller Killer, class<DamageType>damageType, vector HitLocation)
{
	bIsDied=True;
    super.Died(Killer,damageType,HitLocation);
}

function Tick(float delta)
{
	if(Health<0)
	{
		if(!bIsDied && Level.TimeSeconds+1>=LastCheckTime_bIsDied)
		{
			Destroy();
			return;
		}
	}
	else
	{
		LastCheckTime_bIsDied=Level.TimeSeconds;
	}

	if(bFullFreeze)
	{
		Acceleration=vect(0,0,0);
		Velocity.X=0;
		Velocity.Y=0;
		Velocity.Z=0;
	}
	else if(bZedsPause)
	{
		Acceleration.X=0;
		Acceleration.Y=0;
		Velocity.X=0;
		Velocity.Y=0;
	}

	super.Tick(delta);
	PeriodForDamage-=delta;
	if(PeriodForDamage<=0)
	{
		PeriodForDamage=default.PeriodForDamage;
		if(DamageForPeriodOfTime>0)
			AddLastDamage(DamageForPeriodOfTime);
		DamageForPeriodOfTime=0;
	}

	if(bFullFreeze)
	{
		Acceleration=vect(0,0,0);
		Velocity.X=0;
		Velocity.Y=0;
		Velocity.Z=0;
	}
	else if(bZedsPause)
	{
		Acceleration.X=0;
		Acceleration.Y=0;
		Velocity.X=0;
		Velocity.Y=0;
	}
}

simulated function SpawnController()
{
	local ID_RPG_Base_GameType CurrentGame;

	if(ROLE==ROLE_Authority)
	{
		if(ControllerClass!=None && Controller==None)
		{
			Controller=spawn(ControllerClass);
		}

		if(Controller!=None)
		{
			Controller.Possess(self);
			CurrentGame=ID_RPG_Base_GameType(Level.Game);

			if(KFMonsterController(Controller)!=none && CurrentGame!=none)
			{
				KFMonsterController(Controller).bUseFreezeHack=CurrentGame.bZedsPause || CurrentGame.bFullFreeze;
			}
		}
	}
}

simulated function PostBeginPlay()
{
	local float RandomGroundSpeedScale;
	local vector AttachPos;
	local ID_RPG_Base_GameType CurrentGame;
	local int NumEnemies;

	if(ROLE==ROLE_Authority)
	{
		SpawnController();
		SplashTime=0;
		SpawnTime=Level.TimeSeconds;
		EyeHeight=BaseEyeHeight;
		OldRotYaw=Rotation.Yaw;
		if(HealthModifer!=0)
			Health=HealthModifer;

		if(bUseExtendedCollision && MyExtCollision==none)
		{
			MyExtCollision=Spawn(class 'ExtendedZCollision',self);
			MyExtCollision.SetCollisionSize(ColRadius,ColHeight);

			MyExtCollision.bHardAttach=true;
			AttachPos=Location+(ColOffset>>Rotation);
			MyExtCollision.SetLocation(AttachPos);
			MyExtCollision.SetPhysics(PHYS_None);
			MyExtCollision.SetBase(self);
			SavedExtCollision=MyExtCollision.bCollideActors;
		}
	}

	AssignInitialPose();
	// Let's randomly alter the position of our zombies' spines, to give their animations
	// the appearance of being somewhat unique.
	SetTimer(1.0, false);

	//Set Karma Ragdoll skeleton for this character.
	if(KFRagdollName!="")
		RagdollOverride=KFRagdollName; //ClotKarma
	//Log("Ragdoll Skeleton name is :"$RagdollOverride);

	if(bActorShadows && bPlayerShadows && Level.NetMode!=NM_DedicatedServer)
	{
		// decide which type of shadow to spawn
		if(!bRealtimeShadows)
		{
			PlayerShadow=Spawn(class'ShadowProjector',Self,'',Location);
			PlayerShadow.ShadowActor=self;
			PlayerShadow.bBlobShadow=bBlobShadow;
			PlayerShadow.LightDirection=Normal(vect(1,1,3));
			PlayerShadow.LightDistance=320;
			PlayerShadow.MaxTraceDistance=350;
			PlayerShadow.InitShadow();
		}
		else
		{
			RealtimeShadow=Spawn(class'Effect_ShadowController',self,'',Location);
			RealtimeShadow.Instigator=self;
			RealtimeShadow.Initialize();
		}
	}

	bSTUNNED=false;
	DECAP=false;

	// Difficulty Scaling
	if(Level.Game!=none)
	{
		HiddenGroundSpeed=default.HiddenGroundSpeed*1.5;

		RandomGroundSpeedScale=1.0+((1.0-(FRand()*2.0))*0.1); //+/-10%
		GroundSpeed=default.GroundSpeed*RandomGroundSpeedScale;

		CurrentGame=ID_RPG_Base_GameType(Level.Game);
		Lvl=CurrentGame.CurrentMonsterLVL;

		//log("LVL:"@Lvl);
		GroundSpeed*=1+(Lvl-1) *default.SpeedPerLvl;
		AirSpeed*=1+(Lvl-1) *default.SpeedPerLvl;
		WaterSpeed*=1+(Lvl-1) *default.SpeedPerLvl;
		OriginalGroundSpeed=GroundSpeed;

		NumEnemies=CurrentGame.GetPlayersNum();

		// Scale health by lvl
		Health*=1+default.HealthPerLvl* (Lvl-1);
		Health*=1+default.HealthPerPlayer*(NumEnemies-1);
		HeadHealth=Health*default.HeadHealth / 100.0;

		MeleeDamage=Max(((1+(Lvl-1) *DmgPerLvl)*MeleeDamage),1);
		SpinDamConst=Max(((1+(Lvl-1) *DmgPerLvl)*SpinDamConst),1);
		SpinDamRand=Max(((1+(Lvl-1) *DmgPerLvl)*SpinDamRand),1);
		ScreamDamage=Max(((1+(Lvl-1) *DmgPerLvl)*ScreamDamage),1);

		if(Rand(10000)<default.ChanceToBeBoss)
		{
			IsBoss=True;
			Health*=default.BossHpMultiplier;
			MeleeDamage*=1.3;
			GroundSpeed*=1.3;
			bMeleeStunImmune=True;
			HeadHealth=Health*0.7;
			bBoss=True;
			CanBeKilledInstant=False;
		}  

		ExperiencePoints=string(Health*0.1+15*(MeleeDamage+MeleeDamage/7));
		ExperiencePoints=MultiplyNumericValuesFromStrings(ExperiencePoints,"0.1");
		if(IsBoss) 
			ExperiencePoints=MultiplyNumericValuesFromStrings(ExperiencePoints,"3");
		ScoringValue=GetNumericValueFromString(DivideNumericValuesFromStrings(ExperiencePoints,"5"));
		HealthMax=Health;
		bZedsPause=CurrentGame.bZedsPause;
		bFullFreeze=CurrentGame.bFullFreeze;
		bShotAnim=CurrentGame.bZedsPause || CurrentGame.bFullFreeze;
		bDiffAdjusted=true;
	}

	if(Level.NetMode!=NM_DedicatedServer)
	{
		AdditionalWalkAnims[AdditionalWalkAnims.length]=default.MovementAnims[0];
		MovementAnims[0]=AdditionalWalkAnims[Rand(AdditionalWalkAnims.length)];
	}
}

function bool Cloaked()
{
	return bCloaked;
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType>damageType, optional int HitIndex)
{
	local int i;
	local bool bIsHeadshot;
	local float HeadShotCheckScale;
	local float previousHp;
	local int actualDamage;
	local Controller Killer;

	LastDamagedBy=instigatedBy;
	LastDamagedByType=damageType;
	HitMomentum=VSize(momentum);
	LastHitLocation=hitlocation;
	LastMomentum=momentum;

	// Zeds and fire dont mix.
	if(class<ID_Weapon_Base_FlameThrower_DamageType>(damageType)!=none || class<DamTypeSCARPROFAssaultRifle>(damageType)!=none)
	{
		LastBurnDamage=Damage;

		Damage*=1.5;

		if(BurnDown<=0)
		{
			if(HeatAmount>4 || Damage>=15)
			{
				FireDamageClass=class'ID_Weapon_Base_FlameThrower_DamageType';

				bBurnified=true;
				BurnDown=10;
				GroundSpeed*=0.80;
				BurnInstigator=instigatedBy;
				SetTimer(1.0,true);
			}
			else HeatAmount++;
		}
	}
	if(!bDecapitated && class<ID_RPG_Base_Weapon_DamageType>(damageType)!=none &&
		class<ID_RPG_Base_Weapon_DamageType>(damageType).default.CheckForHeadShots)
	{
		HeadShotCheckScale=1.0;

		// Do larger headshot checks if it is a melee attach
		if(class<ID_RPG_Base_Weapon_DamageType_Melee>(damageType)!=none)
		{
			HeadShotCheckScale*=1.25;
		}

		bIsHeadShot=IsHeadShot(hitlocation, normal(momentum), HeadShotCheckScale);
	}
	if(instigatedBy!=none && ID_RPG_Base_HumanPawn(instigatedBy)!=none && instigatedBy.Controller!=none)
	{
		//log("Damage was:" @ Damage);
		for(i=0; i<ID_RPG_Base_HumanPawn(instigatedBy).WeaponMasteries.length; i++)
			Damage+=Damage*ID_RPG_Base_HumanPawn(instigatedBy).WeaponMasteries[i].static.GetDamageMulti(ID_RPG_Base_HumanPawn(instigatedBy), DamageType);
		Damage+=Damage*class'ID_Skill_Damage'.static.GetDamageMulti(self, ID_RPG_Base_HumanPawn(instigatedBy), DamageType);
		
		if(Rand(1000)<1000*class'ID_Skill_DoubleDamage'.static.GetDoubleDamageChance(ID_RPG_Base_HumanPawn(instigatedBy)))
		{
			Damage*=2;
			// NIKE заметка-Выключен ДаблДамаг сообщение! PlayerController(instigatedBy.Controller).ReceiveLocalizedMessage(class'ID_Message_DoubleDamage');
		}

		if(CanBeKilledInstant && Rand(10000)<10000*class'ID_Skill_InstantKill'.static.GetInstantKillChance(ID_RPG_Base_HumanPawn(instigatedBy), damageType))
		{
			Damage=Health*10;
			// NIKE заметка-Выключен ИнстантКилл сообщение! PlayerController(instigatedBy.Controller).ReceiveLocalizedMessage(class'ID_Message_InstantKill');
		}
		//log("Damage after skill:" @ Damage);
	}
	if(damageType!=none && LastDamagedBy!=none && LastDamagedBy.IsPlayerPawn() && LastDamagedBy.Controller!=none)
	{
		if(Controller!=none && KFMonsterController(Controller)!=none)
		{
			KFMonsterController(Controller).AddKillAssistant(LastDamagedBy.Controller, Damage); 
		}
	}
	if((bDecapitated || bIsHeadShot) && class<ID_Weapon_Base_FlameThrower_DamageType>(DamageType)==none)
	{
		if(class<ID_RPG_Base_Weapon_DamageType>(damageType)!=none)
			Damage=Damage*class<ID_RPG_Base_Weapon_DamageType>(damageType).default.HeadShotDamageMult;
		if(instigatedBy!=none && class<ID_RPG_Base_Weapon_DamageType_Melee>(damageType)==none && ID_RPG_Base_HumanPawn(instigatedBy)!=none)
		{
			Damage+=Damage*class'ID_Skill_HeadshotDamage'.static.GetHeadshotDamageMulti(self, ID_RPG_Base_HumanPawn(instigatedBy), DamageType);
		}
		LastDamageAmount=Damage;

		if(!bDecapitated)
		{
			if(bIsHeadShot)
			{
				PlaySound(sound'KF_EnemyGlobalSndTwo.Impact_Skull', SLOT_None,2.0,true,500);

				HeadHealth-=LastDamageAmount;
				if(HeadHealth<=0 || Damage>Health)
				{
					RemoveHead();
					Damage+=1000;
				}
			}
		}
	}

	if(Health-Damage>0 && DamageType!=class'ID_Weapon_Base_M32GL_DamageType')
	{
		Momentum=vect(0,0,0);
	}

	if(class<DamTypeVomit>(DamageType)!=none) // Same rules apply to zombies as players.
	{
		BileCount=7;
		BileInstigator=instigatedBy;
		if(NextBileTime<Level.TimeSeconds)
			NextBileTime=Level.TimeSeconds+BileFrequency;
	}

	previousHp=Health;

	if(damagetype==None)
	{
		if(InstigatedBy!=None)
			warn("No damagetype for damage by "$instigatedby$" with weapon "$InstigatedBy.Weapon);
		DamageType=class'DamageType';
	}

	if(Role<ROLE_Authority)
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	if(Health<=0)
		return;

	if((instigatedBy==None || instigatedBy.Controller==None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController!=None)
		instigatedBy=DelayedDamageInstigatorController.Pawn;

	if(Physics==PHYS_None && DrivenVehicle==None)
		SetMovementPhysics();
	if(Physics==PHYS_Walking && damageType.default.bExtraMomentumZ)
		momentum.Z=FMax(momentum.Z, 0.4*VSize(momentum));
	if(instigatedBy==self)
		momentum*=0.6;
	momentum=momentum/Mass;

	if(Weapon!=None)
		Weapon.AdjustPlayerDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
	if(DrivenVehicle!=None)
		DrivenVehicle.AdjustDriverDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
	if(InstigatedBy!=None && InstigatedBy.HasUDamage())
		Damage*=2;
	actualDamage=Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
	if(DamageType.default.bArmorStops && actualDamage>0)
		actualDamage=ShieldAbsorb(actualDamage);

	Health-=actualDamage;
	if(HitLocation==vect(0,0,0))
		HitLocation=Location;

	PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, Momentum);
	if(Health<=0)
	{
		if(DamageType.default.bCausedByWorld && (instigatedBy==None || instigatedBy==self) && LastHitBy!=None)
			Killer=LastHitBy;
		else if(instigatedBy!=None)
			Killer=instigatedBy.GetKillerController();
		if(Killer==None && DamageType.Default.bDelayedDamage)
			Killer=DelayedDamageInstigatorController;

		if(bPhysicsAnimUpdate)
			SetTearOffMomemtum(momentum);

		Died(Killer, damageType, HitLocation);
	}
	else
	{
		AddVelocity(momentum);
		if(Controller!=None)
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
		if(instigatedBy!=None && instigatedBy!=self)
			LastHitBy=instigatedBy.Controller;
	}
	MakeNoise(1.0);

	bBackstabbed=false;
	DamageForPeriodOfTime+=Damage;

	if(instigatedBy!=none && ID_RPG_Base_PlayerController(instigatedBy.Controller)!=none)
	{
		ID_RPG_Base_PlayerController(instigatedBy.Controller).OnDealDamage(Damage, class, damageType);
		
		if(previousHp>0 && Health<=0)
		{
			ID_RPG_Base_PlayerController(instigatedBy.Controller).OnKill(class, damageType, bIsHeadShot);
		}
	}
}

function RemoveHead()
{
	local int i;

	Intelligence=BRAINS_Retarded; // Headless dumbasses!

	bDecapitated =true;
	DECAP=true;
	DecapTime=Level.TimeSeconds;

	Velocity=vect(0,0,0);
	SetAnimAction('HitF');
	GroundSpeed*=0.8;
	AirSpeed*=0.8;
	WaterSpeed*=0.8;

	// No more raspy breathin'...cuz he has no throat or mouth :S
	AmbientSound=MiscSound;

	//TODO-do we need to inform the controller that we can't move owing to lack of head,
	//		or is that handled elsewhere
	if(Controller!=none && MonsterController(Controller)!=none)
	{
		MonsterController(Controller).Accuracy=-5;  // More chance of missing. (he's headless now, after all) :-D
	}
	
	if(Health>0)
	{
		BleedOutTime=Level.TimeSeconds+ BleedOutDuration;
	}

	//TODO-Find right place for this
	// He's got no head so biting is out.
	if(MeleeAnims[2]=='Claw3')
		MeleeAnims[2]='Claw2';
	if(MeleeAnims[1]=='Claw3')
		MeleeAnims[1]='Claw1';

	// Plug in headless anims if we have them
	for(i=0; i<4; i++)
	{
		if(HeadlessWalkAnims[i]!='' && HasAnim(HeadlessWalkAnims[i]))
		{
			MovementAnims[i]=HeadlessWalkAnims[i];
			WalkAnims[i]=HeadlessWalkAnims[i];
		}
	}

	PlaySound(DecapitationSound, SLOT_Misc,1.30,true,525);
}

function AddLastDamage(int Damage)
{
	local vector loc;
	local ID_HUD_DrawableActor_Damage DamageActor;
	loc=vect(0, 0, 0);
	loc.X=Location.X-50+Rand(100);
	loc.Y=Location.Y-50+Rand(100);
	loc.Z=Location.Z+Rand(60);
	
	DamageActor=Spawn(class'ID_HUD_DrawableActor_Damage',,, loc);
	DamageActor.Damage=Damage;
	if(Damage>15000)
		DamageActor.LifeSpan+=1;
}


simulated function PlayTakeHit(vector HitLocation, int Damage, class<DamageType>DamageType);
simulated function DoDamageFX(Name boneName, int Damage, class<DamageType>DamageType, Rotator r);
simulated function KFSpawnGiblet(class<Gib>GibClass, Vector Location, Rotator Rotation, float GibPerterbation, optional float GibVelocity);
simulated function ProcessHitFX();
simulated function SpawnSeveredGiblet(class<SeveredAppendage>GibClass, Vector Location, Rotator Rotation, float GibPerterbation, rotator SpawnRotation);
simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation);
function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType>damageType, vector Momentum, optional int HitIdx);
function OldPlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType>damageType, vector Momentum, optional int HitIndex);
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm);

function bool IsHeadShot(vector loc, vector ray, float AdditionalScale)
{
	local coords C;
	local vector HeadLoc, B, M, diff;
	local float t, DotMM, Distance;
	local int look;
	local bool bUseAltHeadShotLocation;
	local bool bWasAnimating;

	if(HeadBone=='')
		return False;

	// If we are a dedicated server estimate what animation is most likely playing on the client
	if(Level.NetMode==NM_DedicatedServer)
	{
		if(Physics==PHYS_Falling)
			PlayAnim(AirAnims[0], 1.0, 0.0);
		else if(Physics==PHYS_Walking)
		{
			// Only play the idle anim if we're not already doing a different anim.
			// This prevents anims getting interrupted on the server and borking things up-Ramm

			if(!IsAnimating(0) && !IsAnimating(1))
			{
				if(bIsCrouched)
				{
					PlayAnim(IdleCrouchAnim, 1.0, 0.0);
				}
				else
				{
					bUseAltHeadShotLocation=true;
				}
			}
			else
			{
				bWasAnimating=true;
			}

			if(bDoTorsoTwist)
			{
				SmoothViewYaw=Rotation.Yaw;
				SmoothViewPitch=ViewPitch;

				look=(256*ViewPitch) & 65535;
				if(look>32768)
					look-=65536;

				SetTwistLook(0, look);
			}
		}
		else if(Physics==PHYS_Swimming)
			PlayAnim(SwimAnims[0], 1.0, 0.0);

		if(!bWasAnimating)
		{
			SetAnimFrame(0.5);
		}
	}

	if(bUseAltHeadShotLocation)
	{
		HeadLoc=Location+(OnlineHeadshotOffset>>Rotation);
		AdditionalScale*=OnlineHeadshotScale;
	}
	else
	{
		C=GetBoneCoords(HeadBone);
		HeadLoc=C.Origin+(TruePMHeadHeight*HeadScale*AdditionalScale*C.XAxis);
	}

	// Express snipe trace line in terms of B+tM
	B=loc;
	M=ray*(2.0*CollisionHeight+2.0*CollisionRadius);

	// Find Point-Line Squared Distance
	diff=HeadLoc-B;
	t=M Dot diff;
	if(t>0)
	{
		DotMM=M dot M;
		if(t<DotMM)
		{
			t=t / DotMM;
			diff=diff-(t*M);
		}
		else
		{
			t=1;
			diff-=M;
		}
	}
	else
		t=0;

	Distance=Sqrt(diff Dot diff);

	return (Distance<(HeadRadius*HeadScale*AdditionalScale));
}

defaultproperties
{
     ExperiencePoints="50"
     HealthPerLvl=0.300000
     SpeedPerLvl=0.010000
     DmgPerLvl=0.030000
     CanBeKilledInstant=True
     ChanceToBeBoss=1
     BossHpMultiplier=25
     PeriodForDamage=0.250000
     TruePMHeadHeight=2.000000
     ShockDur=5
     HeadHeight=200.000000
     ControllerClass=Class'IDRPGMod.ID_RPG_Base_Monster_Controller'
}
