class TeslaHusk extends ID_Monster_Zombie_Husk;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax

var class<TeslaBeam> BeamClass;
var TeslaBeam PrimaryBeam;
var float MaxPrimaryBeamRange; // how far Husk can shoot with his tesla gun?
var float MaxChildBeamRange; // max distance from primary target for a chain reaction
var float ChainedBeamRangeExtension; // if pawn is already chained, chain max range is multiplied by this value
// used for optimization
var private float MaxPrimaryBeamRangeSquared, MaxChildBeamRangeSquared;

var float Energy;
var float EnergyMax;
var float EnergyRestoreRate;

var() float DischargeDamage; // beam damage per second
var() float ChainDamageMult; // how much damage drops on the next chain
var() class<DamageType> MyDamageType;
var() byte MaxChainLevel;
var() int MaxChainActors;

var ZedBeamSparks DecapitationSparks;

var bool bChainThoughZED; // chain tesla beam though a zed, which is between target and the husk, to extend firing range
var transient float NextChainZedSearchTime;
var transient float ChainRebuildTimer; // how many seconds between rebuilding chained actors

var float DischargeRate; // time between damaging chained pawns. Do not set it too low due to rounding precission of DischargeDamage
var transient float LastDischargeTime;

// Tesla Husks are able to heal each other.
var() float HealRate;		 // Percent of HealthMax to heal per second
var() float HealEnergyDrain; // amount of energy required to heal 1%
var transient float NextHealAttemptTime, LastHealTime;


struct SActorDamages
{
	var Actor Victim;
	var int Damage;
};
var protected array<SActorDamages> DischargedActors;

simulated function PostBeginPlay()
{
	// Difficulty Scaling
	if(Level.Game!=none && !bDiffAdjusted)
	{
		if(Level.Game.GameDifficulty<2.0)
		{
			// beginner
			DischargeDamage*=0.5;
			EnergyMax*=0.5;
			EnergyRestoreRate*=0.5;
		}
		else if(Level.Game.GameDifficulty<4.0);
		else if(Level.Game.GameDifficulty<5.0)
		{
			//hard
			DischargeDamage*=1.35;
			EnergyMax*=1.35;
			EnergyRestoreRate*=1.35;
			MaxPrimaryBeamRange*=1.35;
			MaxChildBeamRange*=1.35;
		}
		else if(Level.Game.GameDifficulty<7.0)
		{
			// suicidal
			DischargeDamage*=1.55;
			EnergyMax*=1.55;
			EnergyRestoreRate*=1.55;
			MaxPrimaryBeamRange*=1.55;
			MaxChildBeamRange*=1.55;
		}
		else
		{
			// HoE
			DischargeDamage*=1.75;
			EnergyMax*=1.75;
			EnergyRestoreRate*=1.75;
			MaxPrimaryBeamRange*=1.75;
			MaxChildBeamRange*=1.75;
			// disabled due to bugs
			//bChainThoughZED = true;
		}
	}
	Energy = EnergyMax;
	MaxPrimaryBeamRangeSquared = MaxPrimaryBeamRange * MaxPrimaryBeamRange;
	MaxChildBeamRangeSquared = MaxChildBeamRange * MaxChildBeamRange;
	NextHealAttemptTime = Level.TimeSeconds + 5.0;
	
	super.PostBeginPlay();
	
	BurnDamageScale = 1.0; // no fire damage resistance
}

simulated function HideBone(name boneName)
{
	local int BoneScaleSlot;
	local bool bValidBoneToHide;

	if( boneName == LeftThighBone )
	{
		boneScaleSlot = 0;
		bValidBoneToHide = true;
	}
	else if ( boneName == RightThighBone )
	{
		boneScaleSlot = 1;
		bValidBoneToHide = true;
	}
	else if( boneName == RightFArmBone )
	{
		boneScaleSlot = 2;
		bValidBoneToHide = true;
	}
	else if ( boneName == LeftFArmBone )
	{
		boneScaleSlot = 3;
		bValidBoneToHide = true;
	}
	else if ( boneName == HeadBone )
	{
		// Only scale the bone down once
		if( SeveredHead == none )
		{
			bValidBoneToHide = true;
			boneScaleSlot = 4;
		}
		else
		{
			return;
		}
	}
	else if ( boneName == 'spine' )
	{
		bValidBoneToHide = true;
		boneScaleSlot = 5;
	}

	// Only hide the bone if it is one of the arms, legs, or head, don't hide other misc bones
	if( bValidBoneToHide )
	{
		SetBoneScale(BoneScaleSlot, 0.0, BoneName);
	}
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{
	myLevel.AddPrecacheMaterial(Shader'KF_Specimens_Trip_CIRCUS_T.husk_CIRCUS.husk_shader');
}

function TeslaBeam SpawnTeslaBeam()
{
	local TeslaBeam beam;
	
	beam = spawn(BeamClass, self);
	if ( beam != none ) {
		beam.Instigator = self;
	}
	
	return beam;
}


function TeslaBeam SpawnPrimaryBeam()
{
	if ( PrimaryBeam == none ) {
		PrimaryBeam = SpawnTeslaBeam();
		PrimaryBeam.StartActor = self;
		PrimaryBeam.StartBoneName = 'Barrel';
	}
	return PrimaryBeam;
}

function FreePrimaryBeam()
{
	if ( PrimaryBeam != none ) {
		//PrimaryBeam.DestroyChildBeams();
		PrimaryBeam.EndActor = none;
		PrimaryBeam.EffectEndTime = Level.TimeSeconds - 1;
		PrimaryBeam.Instigator = none; // mark to delete
		PrimaryBeam = none;		
	}	
}

function RangedAttack(Actor A)
{
	local float Dist;
	local KFMonster M;
	
	if ( bShotAnim || bDecapitated )
		return;

	Dist = VSize(A.Location - Location);
	
	if ( Physics == PHYS_Swimming )
	{
		SetAnimAction('Claw');
		bShotAnim = true;
	}
	else if ( Energy < 100 && Dist < MeleeRange + CollisionRadius + A.CollisionRadius ) // do melee hits only when low on energy
	{
		bShotAnim = true;
		SetAnimAction('Claw');
		//PlaySound(sound'Claw2s', SLOT_Interact); KFTODO: Replace this
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
	}
	else if ( Energy > 50 && Dist < MaxPrimaryBeamRange*(0.7 + 0.3*frand()) ) 
	{
		bShotAnim = true;

		SetAnimAction('ShootBurns');
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);

		NextFireProjectileTime = Level.TimeSeconds + ProjectileFireInterval + (FRand() * 2.0);
	}
	else if ( bChainThoughZED && Energy > 100 && Controller.Enemy == A && KFPawn(A) != none 
			&& NextChainZedSearchTime < Level.TimeSeconds 
			&& Dist < MaxPrimaryBeamRange + MaxChildBeamRange ) 
	{
		NextChainZedSearchTime = Level.TimeSeconds + 3.0;
		foreach VisibleCollidingActors(class'KFMonster', M, MaxPrimaryBeamRange*0.9) {
			if ( !M.bDeleteMe && M.Health > 0 && TeslaHusk(M) == none 
				&& VSizeSquared(M.Location - A.Location) < MaxChildBeamRangeSquared*0.9
				&& M.FastTrace(A.Location, M.Location) )
			{
				Controller.Target = M;
				RangedAttack(M);
				return;
			}
		}
	}
}


function SpawnTwoShots()
{
	SpawnPrimaryBeam();
	if ( PrimaryBeam == none ) {
	//	log("Unable to spawn Primary Beam!", 'TeslaHusk');
		return;
	}
	PrimaryBeam.EndActor = Controller.Target;
	
	if( Controller!=None && KFDoorMover(Controller.Target)!=None )
	{
		PrimaryBeam.EffectEndTime = Level.TimeSeconds + 1.0;
		Controller.Target.TakeDamage(22,Self,Location,vect(0,0,0), MyDamageType);
		return;
	}
	
	PrimaryBeam.EffectEndTime = Level.TimeSeconds + 2.5;
	GotoState('Shooting');
}

simulated function Tick( float Delta )
{
	if ( Role < ROLE_Authority ) {
		if ( bDecapitated && Health > 0 && DecapitationSparks == none ) {
			SpawnDecapitationEffects();
		}
	}

	Super(ID_RPG_Base_Monster).Tick(Delta);

	if ( Role == ROLE_Authority ) {
		if ( Energy < EnergyMax )
			Energy += EnergyRestoreRate * Delta;
			
		if ( Energy > 150 && NextHealAttemptTime < Level.TimeSeconds ) {
			NextHealAttemptTime = Level.TimeSeconds + 3.0;
			TryHealing();
		}
	}
}

function TryHealing()
{
	local Controller C;
	local KFMonsterController MyMC;
	local TeslaHusk BestPatient;	
	local bool bAnyHusks;
	
	MyMC = KFMonsterController(Controller);
	if ( MyMC == none ) 
		return; // just in case
	
	if ( MyMC.Enemy != none && VSizeSquared(MyMC.Enemy.Location - Location) < MaxPrimaryBeamRangeSquared )
		return; // no healing when need to fight
		
	for ( C=Level.ControllerList; C!=none; C=C.NextController ) {
		if ( TeslaHusk(C.Pawn) != none && C.Pawn != self && C.Pawn.Health > 0 ) {
			bAnyHusks = true;
			if ( (BestPatient == none || BestPatient.Health > C.Pawn.Health) 
					&& VSizeSquared(C.Pawn.Location - Location) < MaxPrimaryBeamRangeSquared )
				BestPatient = TeslaHusk(C.Pawn);
		}
	}
	
	if ( !bAnyHusks )
		NextHealAttemptTime = Level.TimeSeconds + 10.0; // no other husks on the map - so no need to do searching so often
	else if ( BestPatient != none ) {
		if ( BestPatient.Health < BestPatient.HealthMax * 0.90 ) {
			MyMC.Target = BestPatient;
			MyMC.ChangeEnemy(BestPatient, MyMC.CanSee(BestPatient));
			MyMC.GotoState('RangedAttack');
			
			LastHealTime = Level.TimeSeconds + 3.0; // do not heal until beam is spawned
			GotoState('Healing');	
		}
		else
			NextHealAttemptTime = Level.TimeSeconds + 1.0; // if there are other Tesla Husks nearby, then check their health each second
	}
	else
		NextHealAttemptTime = Level.TimeSeconds + 3.0; // there are other Tesla Husks on the map, but not too close
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	// TeslaHusk can't be set on fire, but doesn't have fire resistance either
	BurnDown = 1; // hack to make sure that Tesla Husk won't start burning
	LastBurnDamage = 0x7FFFFFFF;
	super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType,HitIndex);
	BurnDown = 0;
	LastBurnDamage = 0;	
	bBurnified = false;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( PrimaryBeam != none )
		PrimaryBeam.Instigator = none;
	if ( DecapitationSparks != none )
		DecapitationSparks.Destroy();

	AmbientSound = none;
		
	super.Died(Killer, damageType, HitLocation);
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	super.PlayDying(DamageType, HitLoc);

	if ( DecapitationSparks != none )
		DecapitationSparks.Destroy();	
		
	AmbientSound = none;
}

// instead of roaming around, activate self-destruct
function RemoveHead()
{
	Intelligence = BRAINS_Retarded; // Headless dumbasses!

	bDecapitated  = true;
	DECAP = true;
	DecapTime = Level.TimeSeconds;

	Velocity = vect(0,0,0);
	SetAnimAction('KnockDown');
	SetGroundSpeed(0);
	AirSpeed = 0;
	WaterSpeed = 0;

	// No more raspy breathin'...cuz he has no throat or mouth :S
	AmbientSound = MiscSound;

	//TODO - do we need to inform the controller that we can't move owing to lack of head,
	//	  or is that handled elsewhere
	if ( Controller != none )
	{
		MonsterController(Controller).Accuracy = -5;  // More chance of missing. (he's headless now, after all) :-D
	}

	// do not causeadditional hurty -- PooSH
	/*
	// Head explodes, causing additional hurty.
	if( KFPawn(LastDamagedBy)!=None )
	{
		TakeDamage( LastDamageAmount + 0.25 * HealthMax , LastDamagedBy, LastHitLocation, LastMomentum, LastDamagedByType);

		if ( BurnDown > 0 )
		{
			KFSteamStatsAndAchievements(KFPawn(LastDamagedBy).PlayerReplicationInfo.SteamStatsAndAchievements).AddBurningDecapKill(class'KFGameType'.static.GetCurrentMapName(Level));
		}
	}
	*/

	// super.TakeDamage(LastDamageAmount) isn't called yet, so set self-destruct sequence only if
	// zed can survive the hit
	if( Health > LastDamageAmount && Energy > 50 ) {
		SpawnDecapitationEffects();
		BleedOutTime = Level.TimeSeconds +  BleedOutDuration;
		GotoState('SelfDestruct');
	}


	PlaySound(DecapitationSound, SLOT_Misc,1.30,true,525);
}


// Tesla Husk doesn't get stunned by weak sniper shots
function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HitIdx )
{
	super(KFMonster).PlayHit(Damage, InstigatedBy, HitLocation, damageType,  Momentum, HitIdx );
}

simulated function Destroyed()
{
	if ( PrimaryBeam != none )
		PrimaryBeam.Destroy();
		
	if ( DecapitationSparks != none )
		DecapitationSparks.Destroy();
		
	super.Destroyed();
}

simulated function SpawnDecapitationEffects()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;
		
	DecapitationSparks = spawn(class'ZedBeamSparks', self,, GetBoneCoords(HeadBone).Origin, Rotation);
}

simulated function int DoAnimAction( name AnimName )
{
	// faked animation with forces to play the end of shoot animation (where Huks is putting his gun down)
	if ( AnimName == 'ShootBurnsEnd' ) {
		PlayAnim('ShootBurns');
		SetAnimFrame(120, 0, 1);
		return 0;
	}
	return super.DoAnimAction(AnimName);
}

function float RangedAttackTime()
{
	return 5.0;
}

state Healing
{
	ignores TryHealing;
	
	function BeginState()
	{
		//log("Entering Healing State @ " $ Level.TimeSeconds, 'TeslaHusk');
		
		LastHealTime = Level.TimeSeconds + 3.0; // do not heal until beam is spawned
	}

	function EndState()
	{
		local name SeqName;
		local float AnimFrame, AnimRate;

		//log("Exiting Healing State @ " $ Level.TimeSeconds, 'TeslaHusk');
		
		NextHealAttemptTime = Level.TimeSeconds + 5.0; 
		FreePrimaryBeam();

		// end shooting animation
		GetAnimParams(0, SeqName, AnimFrame, AnimRate);
		if ( SeqName == 'ShootBurns' && AnimFrame < 120 )
			SetAnimAction('ShootBurnsEnd'); // faked anim
			
		Controller.Enemy = none;
		KFMonsterController(Controller).FindNewEnemy();
	}
	
	function SpawnTwoShots()
	{
		SpawnPrimaryBeam();
		if ( Controller != none )
			PrimaryBeam.EndActor = Controller.Target;
		PrimaryBeam.EffectEndTime = Level.TimeSeconds + 2.5;
		LastHealTime = Level.TimeSeconds; // start healing
	}
	
	function bool FlipOver()
	{
		if ( global.FlipOver() ) {
			GotoState('');
			return true;
		}
		return false;
	}	
	
	function Tick(float DeltaTime)
	{
		local TeslaHusk Patient;
		local int HealthToAdd;
		
		super.Tick(DeltaTime);
		
		if ( Level.TimeSeconds >= LastHealTime+0.25 ) {
			if ( PrimaryBeam == none || Energy <= 0 || Level.TimeSeconds > PrimaryBeam.EffectEndTime ) {
				GotoState('');
				return;
			}

			NextHealAttemptTime = Level.TimeSeconds + 0.25;
			Patient = TeslaHusk(PrimaryBeam.EndActor);
			if ( Patient == none || Patient.Health <= 0 || Patient.Health >= Patient.HealthMax )
				GotoState('');
			else {
				
				HealthToAdd = min(Patient.HealthMax*HealRate*(Level.TimeSeconds-LastHealTime), Patient.HealthMax - Patient.Health);
				if ( HealthToAdd*HealEnergyDrain > Energy )
					HealthToAdd = Energy / HealEnergyDrain;
				Patient.Health += HealthToAdd;
				Energy -= HealthToAdd*HealEnergyDrain;
				LastHealTime = Level.TimeSeconds;
			}
		}
	}	
}


// todo:  make custom controller, moving states there
state Shooting
{
	ignores TryHealing;

	function BeginState()
	{
		//log("Entering Shooting State @ " $ Level.TimeSeconds, 'TeslaHusk');
		
		if ( PrimaryBeam == none ) {
			SpawnPrimaryBeam();
			PrimaryBeam.EndActor = Controller.Target;
		}

		PrimaryBeam.EffectEndTime = Level.TimeSeconds + 2.5;
		BuildChain();
		LastDischargeTime = Level.TimeSeconds;
		Discharge(DischargeRate);
	}
	
	
	function EndState()
	{
		local name SeqName;
		local float AnimFrame, AnimRate;
		
		//log("Exiting Shooting State @ " $ Level.TimeSeconds, 'TeslaHusk');

		FreePrimaryBeam();
		
		// end shooting animation
		GetAnimParams(0, SeqName, AnimFrame, AnimRate);
		if ( SeqName == 'ShootBurns' && AnimFrame < 120 )
			SetAnimAction('ShootBurnsEnd'); // faked anim
	}
	
	function BuildChain()
	{
		local int ChainsRemaining;
		
		ChainRebuildTimer = default.ChainRebuildTimer;
		ChainsRemaining = MaxChainActors;
		SpawnChildBeams(PrimaryBeam, 1, ChainsRemaining);		
	}

	function SpawnChildBeams(TeslaBeam MasterBeam, byte level, out int ChainsRemaining)
	{
		local Pawn P;
		local TeslaBeam ChildBeam;
		local int i;
		
		if ( MasterBeam == none || level > MaxChainLevel || ChainsRemaining <= 0 )
			return; 
			
		for ( i=0; i<MasterBeam.ChildBeams.length; ++i ) {
			if ( MasterBeam.ChildBeams[i] == none )
				MasterBeam.ChildBeams.remove(i--, 1);
		}
		
		if ( MasterBeam.EndActor == none || MasterBeam.EndActor.bDeleteMe )
			return;
			
		foreach MasterBeam.EndActor.VisibleCollidingActors(class'Pawn', P, MaxChildBeamRange, MasterBeam.EndActor.Location) {
			if ( !P.bDeleteMe && P != MasterBeam.StartActor && P != MasterBeam.EndActor 
					&& TeslaHusk(P) == none && !PrimaryBeam.IsChainedTo(P) ) 
			{
				i = MasterBeam.ChildIndex(P);
				if ( i != -1 ) {
					ChildBeam = MasterBeam.ChildBeams[i];
					ChildBeam.EffectEndTime = PrimaryBeam.EffectEndTime;
				}
				else {
					ChildBeam = SpawnTeslaBeam();
					if ( ChildBeam != none ) {
						ChildBeam.StartActor = MasterBeam.EndActor;
						ChildBeam.EndActor = P;
						ChildBeam.EffectEndTime = PrimaryBeam.EffectEndTime;
						MasterBeam.ChildBeams[MasterBeam.ChildBeams.length] = ChildBeam;
					}
				}
				if ( --ChainsRemaining <= 0 )
					return;
			}
		}
		
		for ( i=0; i<MasterBeam.ChildBeams.length && ChainsRemaining > 0; ++i ) {
			SpawnChildBeams(MasterBeam.ChildBeams[i], level+1, ChainsRemaining);
		}
	}

	function ChainDamage(TeslaBeam Beam, float Damage, byte ChainLevel)
	{
		local int i;
		local float DmgMult;
		
		if ( Beam == none || Beam.EndActor == none || Energy < 0)
			return;
			
		Damage = clamp(Damage, 1, Energy);
		
		// look if actor already received a damage during this discharge
		for ( i=0; i<DischargedActors.length; ++i ) {
			if ( DischargedActors[i].Victim == Beam.EndActor ) {
				if ( DischargedActors[i].Damage >= Damage )
					return; // Victim already received enough damage
				else {
					Damage -= DischargedActors[i].Damage;
					DischargedActors[i].Damage += Damage;
					break;
				}
			}
		}
		if ( i == DischargedActors.length ) {
			// new victim
			DischargedActors.insert(i, 1);
			DischargedActors[i].Victim = Beam.EndActor;
			DischargedActors[i].Damage = Damage;
		}
		
		// deal higher damage to monsters, but do not drain energy quicker
		DmgMult = 1.0;
		if ( KFMonster(Beam.EndActor) != none ) {
			if ( ZombieFleshpound(Beam.EndActor) != none )
				DmgMult = 20.0;
			else
				DmgMult = 3.0;
		}
		// if pawn is already chained, then damage him until he gets out of the primary range 
		Beam.SetBeamLocation(); // ensure that StartEffect and EndEffect are set 
		if ( VSizeSquared(Beam.EndEffect - Beam.StartEffect) <= MaxPrimaryBeamRangeSquared * ChainedBeamRangeExtension 
				&& FastTrace(Beam.EndEffect, Beam.StartEffect) ) 
		{
			Beam.EndActor.TakeDamage(Damage*DmgMult, self, Beam.EndActor.Location, Beam.SetBeamRotation(), MyDamageType);
			Energy -= Damage;
			
			Damage *= ChainDamageMult;
			ChainLevel++;
			if ( Damage > 0 && ChainLevel <= MaxChainLevel) {
				for ( i=0; i<Beam.ChildBeams.length && Energy > 0; ++i )			
					ChainDamage(Beam.ChildBeams[i], Damage, ChainLevel);
			}
		}
		else {
			Beam.Instigator = none; // delete beam
		}
	}
	
	
	function Discharge(float DeltaTime)
	{
		LastDischargeTime = Level.TimeSeconds;
		DischargedActors.length = 0;
		ChainDamage(PrimaryBeam, DischargeDamage*DeltaTime, 0);
		if (Energy <= 0)
			GotoState(''); // out of energy - stop shooting
	}
	
	function bool FlipOver()
	{
		if ( global.FlipOver() ) {
			GotoState('');
			return true;
		}
		return false;
	}
	
	
	function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);

		//log("Shooting.Tick @ " $ Level.TimeSeconds $ ":" @"Energy="$Energy @"PrimaryBeam="$PrimaryBeam, 'TeslaHusk');
		
		ChainRebuildTimer -= DeltaTime;
		if ( Energy <= 0 || PrimaryBeam == none || PrimaryBeam.EndActor == none || Level.TimeSeconds > PrimaryBeam.EffectEndTime ) {
			GotoState('');
		}
		else if ( LastDischargeTime + DischargeRate <= Level.TimeSeconds ) {
			if ( ChainRebuildTimer <= 0 )
				BuildChain();
				
			Discharge(Level.TimeSeconds - LastDischargeTime); // damage chained actors
		}
			
	}
}

state SelfDestruct
{
	ignores PlayDirectionalHit, RangedAttack, MeleeDamageTarget;
	
	function BeginState()
	{
		local TeslaHuskEMPCharge MyNade;
		
		MyNade = spawn(class'TeslaHuskEMPCharge', self,, Location);
		if ( MyNade != none ) {
			AttachToBone(MyNade, RootBone);
			MyNade.SetTimer(3.0, false);
			MyNade.bTimerSet = true;
			MyNade.Damage = max(20, Energy * 0.45);
		}
		else {
			// wtf?
			Died(LastDamagedBy.Controller,class'DamTypeBleedOut',Location);
		}
		
		
	}
	
	function bool CanGetOutOfWay()
	{
		return false;
	}

	// takes only 25% of damage
	function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
	{
		global.TakeDamage(Damage*0.25,instigatedBy,hitlocation,momentum,damageType,HitIndex);
	}
}

defaultproperties
{
     BeamClass=Class'IDRPGMod.TeslaBeam'
     MaxPrimaryBeamRange=300.000000
     MaxChildBeamRange=150.000000
     ChainedBeamRangeExtension=1.200000
     Energy=200.000000
     EnergyMax=200.000000
     EnergyRestoreRate=20.000000
     DischargeDamage=20.000000
     ChainDamageMult=0.700000
     MyDamageType=Class'IDRPGMod.DamTypeTesla'
     MaxChainLevel=5
     MaxChainActors=20
     DischargeRate=0.250000
     HealRate=0.250000
     HealEnergyDrain=0.200000
     ProjectileFireInterval=5.000000
     BurnDamageScale=1.000000
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Husk.Husk_Talk'
     BleedOutDuration=5.000000
     MiscSound=Sound'KF_FY_ZEDV2SND.foley.WEP_ZEDV2_Projectile_Loop'
     DecapitationSound=Sound'KF_FY_ZEDV2SND.Fire.WEP_ZEDV2_Secondary_Explode'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Bloat.Bloat_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Husk.Husk_Jump'
     ProjectileBloodSplatClass=None
     DetachedArmClass=Class'IDRPGMod.SeveredArmTeslaHusk'
     DetachedLegClass=Class'IDRPGMod.SeveredLegTeslaHusk'
     DetachedHeadClass=Class'IDRPGMod.SeveredHeadTeslaHusk'
     DetachedSpecialArmClass=Class'IDRPGMod.SeveredGunTeslaHusk'
     HeadHealth=400.000000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Husk.Husk_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Husk.Husk_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Husk.Husk_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Husk.Husk_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Husk.Husk_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Husk.Husk_Challenge'
     ScoringValue=25
     GroundSpeed=140.000000
     WaterSpeed=120.000000
     HealthMax=800.000000
     Health=800
     MenuName="Tesla Husk"
     AmbientSound=Sound'KF_BaseHusk_CIRCUS.Husk_IdleLoop'
     Mesh=SkeletalMesh'DZResPack.TeslaHusk'
     Skins(0)=Shader'DZResPack.THusk_sh'
}
