// Chainsaw Zombie Monster for KF Invasion gametype
// He's not quite as speedy as the other Zombies, But his attacks are TRULY damaging.
class ZombieBigScrakie extends ID_RPG_Base_Monster;

///#exec OBJ LOAD FILE=PlayerSounds.uax

//----------------------------------------------------------------------------
// NOTE: All Variables are declared in the base class to eliminate hitching
//----------------------------------------------------------------------------
var(Sounds) sound   SawAttackLoopSound; // THe sound for the saw revved up, looping
var(Sounds) sound   ChainSawOffSound;   //The sound of this zombie dieing without a head

var         bool    bCharging;          // Scrake charges when his health gets low
var()       float   AttackChargeRate;   // Ratio to increase scrake movement speed when charging and attacking

// Exhaust effects
var()	class<VehicleExhaustEffect>	ExhaustEffectClass; // Effect class for the exhaust emitter
var()	VehicleExhaustEffect 		ExhaustEffect;
var 		bool	bNoExhaustRespawn;

replication
{
	reliable if(Role == ROLE_Authority)
		bCharging;
}


simulated function PostNetBeginPlay()
{
	EnableChannelNotify ( 1,1);
	AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
	super.PostNetBeginPlay();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SpawnExhaustEmitter();
}
// Make the scrakes's ambient scale higher, since there are just a few, and thier chainsaw need to be heard from a distance
simulated function CalcAmbientRelevancyScale()
{
        // Make the zed only relevant by thier ambient sound out to a range of 30 meters
    	CustomAmbientRelevancyScale = 1500/(100 * SoundRadius);
}

simulated function PostNetReceive()
{
	if (bCharging)
		MovementAnims[0]='ChargeF';
	else if( !(bCrispified && bBurnified) )
        MovementAnims[0]=default.MovementAnims[0];
}

// This zed has been taken control of. Boost its health and speed
function SetMindControlled(bool bNewMindControlled)
{
    if( bNewMindControlled )
    {
        NumZCDHits++;

        // if we hit him a couple of times, make him rage!
        if( NumZCDHits > 1 )
        {
            if( !IsInState('RunningToMarker') )
            {
                GotoState('RunningToMarker');
            }
            else
            {
                NumZCDHits = 1;
                if( IsInState('RunningToMarker') )
                {
                    //GotoState('');
                }
            }
        }
        else
        {
            if( IsInState('RunningToMarker') )
            {
                //GotoState('');
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

// Handle the zed being commanded to move to a new location
function GivenNewMarker()
{
    if( bCharging) // && NumZCDHits > 1
    {
        if( !IsInState('RunningToMarker') )
          GotoState('RunningToMarker');
    }
    else
    {
        GotoState('');
    }
}

simulated function SetBurningBehavior()
{
    // If we're burning stop charging
    if( Role == Role_Authority && !IsInState('RunningState') )
			{
                   super.SetBurningBehavior();
                   GotoState('RunningState'); // Continue running then burnified 
			}
	else if( Role == Role_Authority && IsInState('RunningState') )
	   return;

    super.SetBurningBehavior();
}

simulated function SpawnExhaustEmitter()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( ExhaustEffectClass != none )
		{
			ExhaustEffect = Spawn(ExhaustEffectClass, self);

			if ( ExhaustEffect != none )
			{
				AttachToBone(ExhaustEffect, 'Chainsaw_lod1');
				ExhaustEffect.SetRelativeLocation(vect(0, -20, 0));
			}
		}
	}
}

simulated function UpdateExhaustEmitter()
{
	local byte Throttle;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( ExhaustEffect != none )
		{
			if ( bShotAnim )
			{
				Throttle = 3;
			}
			else
			{
				Throttle = 0;
			}
		}
		else
		{
			if ( !bNoExhaustRespawn )
			{
				SpawnExhaustEmitter();
			}
		}
	}
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	UpdateExhaustEmitter();
}


function RangedAttack(Actor A)
{
	if ( bShotAnim || Physics == PHYS_Swimming)
		return;
	else if ( CanAttack(A) )
	{
		bShotAnim = true;
		SetAnimAction(MeleeAnims[Rand(2)]);
		CurrentDamType = ZombieDamType[0];
		//PlaySound(sound'Claw2s', SLOT_None); KFTODO: Replace this
		GoToState('SawingLoop');
	}

	//if( !bShotAnim && !bDecapitated && Health/HealthMax < 0.5 )
        if (!bDecapitated)
		GoToState('RunningState');
}

state RunningState
{
	// Don't override speed in this state
    function bool CanSpeedAdjust()
    {
        return false;
    }

	function BeginState()
	{
		GroundSpeed = OriginalGroundSpeed * 3.5;
		bCharging = true;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();

		NetUpdateTime = Level.TimeSeconds - 1;
	}

	function EndState()
	{
		GroundSpeed = GetOriginalGroundSpeed();
		bCharging = False;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();
	}

	function RemoveHead()
	{
		GoToState('');
		Global.RemoveHead();
	}

    function RangedAttack(Actor A)
    {
    	if ( bShotAnim || Physics == PHYS_Swimming)
    		return;
    	else if ( CanAttack(A) )
    	{
    		bShotAnim = true;
    		SetAnimAction(MeleeAnims[Rand(2)]);
    		CurrentDamType = ZombieDamType[0];
    		GoToState('SawingLoop');
    	}
    }
}

// State where the zed is charging to a marked location.
// Not sure if we need this since its just like RageCharging,
// but keeping it here for now in case we need to implement some
// custom behavior for this state
state RunningToMarker extends RunningState
{
}


State SawingLoop
{
	// Don't override speed in this state
    function bool CanSpeedAdjust()
    {
        return false;
    }

    function bool CanGetOutOfWay()
    {
        return false;
    }

	function BeginState()
	{
        local float ChargeChance, RagingChargeChance;

        // Decide what chance the scrake has of charging during an attack
        if( Level.Game.GameDifficulty < 2.0 )
        {
            ChargeChance = 0.25;
            RagingChargeChance = 0.5;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            ChargeChance = 0.5;
            RagingChargeChance = 0.70;
        }
        else if( Level.Game.GameDifficulty < 7.0 )
        {
            ChargeChance = 0.65;
            RagingChargeChance = 0.85;
        }
        else // Hardest difficulty
        {
            ChargeChance = 0.95;
            RagingChargeChance = 1.0;
        }

        // Randomly have the scrake charge during an attack so it will be less predictable
        if(true)                 //(Health/HealthMax < 0.5 && FRand() <= RagingChargeChance ) || FRand() <= ChargeChance )
		{
            GroundSpeed = OriginalGroundSpeed * AttackChargeRate;
    		bCharging = true;
    		if( Level.NetMode!=NM_DedicatedServer )
    			PostNetReceive();

    		NetUpdateTime = Level.TimeSeconds - 1;
		}
	}

	function RangedAttack(Actor A)
	{
		if ( bShotAnim )
			return;
		else if ( CanAttack(A) )
		{
                        // Catch the victim and kill the bastard!!! KFDS
			KFHumanPawn(A).DisableMovement(3.800000);
                        Acceleration = vect(0,0,0);
                        // He have weapons? extreme? Hmmm Take the weapons from him :D KFDS
                        //KFHumanPawn(A).DropWeaponsFromMonsterPunch();
			bShotAnim = true;
			//MeleeDamage = default.MeleeDamage*0.6;
                        MeleeDamage = default.MeleeDamage*1.1;
			SetAnimAction('SawImpaleLoop');
			CurrentDamType = ZombieDamType[0];
			if( AmbientSound != SawAttackLoopSound )
			{
                           AmbientSound=SawAttackLoopSound;
			}
		}
		else GoToState('');
	}
	function AnimEnd( int Channel )
	{
		Super.AnimEnd(Channel);
		if( Controller!=None && Controller.Enemy!=None )
			RangedAttack(Controller.Enemy); // Keep on attacking if possible.
	}

	function Tick( float Delta )
	{
        // Keep the scrake moving toward its target when attacking
    	if( Role == ROLE_Authority && bShotAnim && !bWaitForAnim )
    	{
    		if( LookTarget!=None )
    		{
    		    Acceleration = AccelRate * Normal(LookTarget.Location - Location);
    		}
        }

		global.Tick(Delta);
	}

	function EndState()
	{
		AmbientSound=default.AmbientSound;
		MeleeDamage= default.MeleeDamage;

		GroundSpeed = GetOriginalGroundSpeed();
		bCharging = False;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();
	}
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
	local int StunChance;

	StunChance = rand(6);

	if( Level.TimeSeconds - LastPainAnim < MinTimeBetweenPainAnims )
		return;

	if( Damage>=150 || (DamageType.name=='DamTypeStunNade' && StunChance>3) || (DamageType.name=='DamTypeFrag' && StunChance>3) || (DamageType.name=='DamTypeStunPipeBomb' && StunChance>3) || (DamageType.name=='DamTypeStunM79Grenade' && StunChance>3) 
	|| (DamageType.name=='DamTypeStunM79GrenadeImpact' && StunChance>3) || (DamageType.name=='DamTypeCrossbowHeadshot' && Damage>=200) || (DamageType.name=='DamTypeL96AWPLLI' && Damage>=200) )
		PlayDirectionalHit(HitLocation);

	LastPainAnim = Level.TimeSeconds;

	if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
		return;

	LastPainSound = Level.TimeSeconds;
	PlaySound(HitSound[0], SLOT_Pain,1.25,,400);
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{	
	local Vector X,Y,Z;
	local bool bIsHeadShot;
	local float HeadShotCheckScale;

	GetAxes(Rotation, X,Y,Z);	

    HeadShotCheckScale = 1.0;

    // Do larger headshot checks if it is a melee attach
    if( class<DamTypeMelee>(damageType) != none )
    {
        HeadShotCheckScale *= 1.25;
    }

    bIsHeadShot = IsHeadShot(Hitlocation, normal(Momentum), 1.0);

	// He takes less damage to small arms fire (non explosives)
	// Frags and LAW rockets will bring him down way faster than bullets and shells.


      Damage *= 0.15;


    if (DamageType == class 'DamTypeBurned' || DamageType == class 'DamTypeFlamethrower')
     {
        Damage = 0;
        bBurnified = false;
        bCrispified = false;
     }

	 if ( class<KFProjectileWeaponDamageType>(DamageType) != none )
	{
		PlaySound(class'ZombieBigScrakieSND'.default.ImpactSounds[rand(3)],, 128);
	}
	else if ( class<DamTypeChainsaw>(DamageType) != none )
	{
		PlaySound(Sound'KF_ChainsawSnd.Chainsaw_Impact_Conc1',, 128);
	}
	else if ( class<DamTypeMelee>(DamageType) != none )
	{
		PlaySound(Sound'KF_KnifeSnd.KnifeImpactBase.Knife_HitConc3',, 128);
	}

	if ( class<DamTypeFlamethrower>(DamageType) == none && class<DamTypeBurned>(DamageType) == none && class<DamTypeVomit>(DamageType) == none )
	{
		Spawn(class'ArmorHitEmitter', InstigatedBy,, HitLocation, rotator(Momentum));
	}
	 
	 
    Super.takeDamage(Damage, instigatedBy, hitLocation, momentum, damageType,HitIndex) ;
}



simulated function int DoAnimAction( name AnimName )
{
	if( AnimName=='SawZombieAttack1' || AnimName=='SawZombieAttack2' )
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

// The animation is full body and should set the bWaitForAnim flag
simulated function bool AnimNeedsWait(name TestAnim)
{
    if( TestAnim == 'SawImpaleLoop' || TestAnim == 'DoorBash' )
    {
        return true;
    }

    return false;
}

function PlayDyingSound()
{
	if( Level.NetMode!=NM_Client )
	{
    	if ( bGibbed )
    	{
            // Do nothing for now
    		PlaySound(GibGroupClass.static.GibSound(), SLOT_Pain,2.0,true,525);
    		return;
    	}

        if( bDecapitated )
        {

            PlaySound(HeadlessDeathSound, SLOT_Pain,1.30,true,525);
    	}
    	else
    	{
            PlaySound(DeathSound[0], SLOT_Pain,1.30,true,525);
    	}

    	PlaySound(ChainSawOffSound, SLOT_Misc, 2.0,,525.0);
	}
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    AmbientSound = none;

	if ( ExhaustEffect != none )
	{
		ExhaustEffect.Destroy();
    	ExhaustEffect = none;
    	bNoExhaustRespawn = true;
    }

    super.Died( Killer, damageType, HitLocation );
}

simulated function ProcessHitFX()
{
    local Coords boneCoords;
	local class<xEmitter> HitEffects[4];
	local int i,j;
    local float GibPerterbation;

    if( (Level.NetMode == NM_DedicatedServer) || bSkeletized || (Mesh == SkeletonMesh))
    {
		SimHitFxTicker = HitFxTicker;
        return;
    }

    for ( SimHitFxTicker = SimHitFxTicker; SimHitFxTicker != HitFxTicker; SimHitFxTicker = (SimHitFxTicker + 1) % ArrayCount(HitFX) )
    {
		j++;
		if ( j > 30 )
		{
			SimHitFxTicker = HitFxTicker;
			return;
		}

        if( (HitFX[SimHitFxTicker].damtype == None) || (Level.bDropDetail && (Level.TimeSeconds - LastRenderTime > 3) && !IsHumanControlled()) )
            continue;

		//log("Processing effects for damtype "$HitFX[SimHitFxTicker].damtype);

		if( HitFX[SimHitFxTicker].bone == 'obliterate' && !class'GameInfo'.static.UseLowGore())
		{
			SpawnGibs( HitFX[SimHitFxTicker].rotDir, 1);
			bGibbed = true;
			Destroy();
			return;
		}

        boneCoords = GetBoneCoords( HitFX[SimHitFxTicker].bone );

        if ( !Level.bDropDetail && !class'GameInfo'.static.NoBlood() && !bSkeletized && !class'GameInfo'.static.UseLowGore() )
        {
            //AttachEmitterEffect( BleedingEmitterClass, HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );

			HitFX[SimHitFxTicker].damtype.static.GetHitEffects( HitEffects, Health );

			if( !PhysicsVolume.bWaterVolume ) // don't attach effects under water
			{
				for( i = 0; i < ArrayCount(HitEffects); i++ )
				{
					if( HitEffects[i] == None )
						continue;

					  AttachEffect( HitEffects[i], HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );
				}
			}
		}
        if ( class'GameInfo'.static.UseLowGore() )
			HitFX[SimHitFxTicker].bSever = false;

        if( HitFX[SimHitFxTicker].bSever )
        {
            GibPerterbation = HitFX[SimHitFxTicker].damtype.default.GibPerterbation;

            switch( HitFX[SimHitFxTicker].bone )
            {
                case 'obliterate':
                    break;

                case LeftThighBone:
                	if( !bLeftLegGibbed )
					{
	                    SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
	                    bLeftLegGibbed=true;
                    }
                    break;

                case RightThighBone:
                	if( !bRightLegGibbed )
					{
	                    SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
	                    bRightLegGibbed=true;
                    }
                    break;

                case LeftFArmBone:
                	if( !bLeftArmGibbed )
					{
	                    SpawnSeveredGiblet( DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;;
	                    bLeftArmGibbed=true;
                    }
                    break;

                case RightFArmBone:
                	if( !bRightArmGibbed )
					{
	                    SpawnSeveredGiblet( DetachedSpecialArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
	                    bRightArmGibbed=true;
                    }
                    break;

                case 'head':
                    if( !bHeadGibbed )
                    {
                        if ( HitFX[SimHitFxTicker].damtype == class'DamTypeDecapitation' )
                        {
                            DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false);
                        }
                        else if( HitFX[SimHitFxTicker].damtype == class'DamTypeMeleeDecapitation' )
                        {
                            DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, true);
                        }

                      	bHeadGibbed=true;
                  	}
                    break;
            }


			if( HitFX[SimHitFXTicker].bone != 'Spine' && HitFX[SimHitFXTicker].bone != FireRootBone &&
                HitFX[SimHitFXTicker].bone != 'head' && Health <=0 )
            	HideBone(HitFX[SimHitFxTicker].bone);
        }
    }
}

// Maybe spawn some chunks when the player gets obliterated
simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation)
{
	bGibbed = true;
	PlayDyingSound();

    if ( ExhaustEffect != none )
    {
		ExhaustEffect.Destroy();
    	ExhaustEffect = none;
    	bNoExhaustRespawn = true;
    }

    if ( class'GameInfo'.static.UseLowGore() )
		return;

	if( ObliteratedEffectClass != none )
		Spawn( ObliteratedEffectClass,,, Location, HitRotation );

    super.SpawnGibs(HitRotation,ChunkPerterbation);

    if ( FRand() < 0.1 )
	{
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;

		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		SpawnSeveredGiblet( DetachedSpecialArmClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		SpawnSeveredGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation, HitRotation );
	}
	else if ( FRand() < 0.25 )
	{
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;

		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		if ( FRand() < 0.5 )
		{
            KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
			SpawnSeveredGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation, HitRotation );
		}
	}
	else if ( FRand() < 0.35 )
	{
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
    	SpawnSeveredGiblet( DetachedLegClass, Location, HitRotation, ChunkPerterbation, HitRotation );
	}
	else if ( FRand() < 0.5 )
	{
		KFSpawnGiblet( class 'KFMod.KFGibBrainb',Location, HitRotation, ChunkPerterbation, 500 ) ;
		KFSpawnGiblet( class 'KFMod.KFGibBrain',Location, HitRotation, ChunkPerterbation, 500 ) ;
		SpawnSeveredGiblet( DetachedArmClass, Location, HitRotation, ChunkPerterbation, HitRotation );
	}
}

defaultproperties
{
     SawAttackLoopSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Impale'
     ChainSawOffSound=SoundGroup'KF_ChainsawSnd.Chainsaw_Deselect'
     AttackChargeRate=2.500000
     ExhaustEffectClass=Class'KFMod.ChainsawExhaust'
     MeleeAnims(0)="SawZombieAttack1"
     MeleeAnims(1)="SawZombieAttack2"
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Talk'
     BleedOutDuration=6.000000
     ZombieFlag=3
     MeleeDamage=60
     damageForce=-110000
     bFatAss=True
     KFRagdollName="Scrake_Trip"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Chainsaw_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Jump'
     bUseExtendedCollision=True
     ColOffset=(Z=55.000000)
     ColRadius=29.000000
     ColHeight=18.000000
     SeveredArmAttachScale=1.100000
     SeveredLegAttachScale=1.100000
     DetachedArmClass=Class'KFChar.SeveredArmScrake'
     DetachedLegClass=Class'KFChar.SeveredLegScrake'
     DetachedHeadClass=Class'KFChar.SeveredHeadScrake'
     DetachedSpecialArmClass=Class'KFChar.SeveredArmScrakeSaw'
     PlayerCountHealthScale=0.500000
     PoundRageBumpDamScale=0.010000
     OnlineHeadshotOffset=(X=22.000000,Y=5.000000,Z=58.000000)
     OnlineHeadshotScale=1.500000
     HeadHealth=8500.000000
     PlayerNumHeadHealthScale=0.250000
     MotionDetectorThreat=3.000000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ScoringValue=1000
     IdleHeavyAnim="SawZombieIdle"
     IdleRifleAnim="SawZombieIdle"
     MeleeRange=40.000000
     GroundSpeed=182.000000
     WaterSpeed=168.000000
     HealthMax=9000.000000
     Health=8500
     MenuName="The Big Scrakie"
     ControllerClass=Class'IDRPGMod.SawZombieController'
     MovementAnims(0)="SawZombieWalk"
     MovementAnims(1)="SawZombieWalk"
     MovementAnims(2)="SawZombieWalk"
     MovementAnims(3)="SawZombieWalk"
     WalkAnims(0)="SawZombieWalk"
     WalkAnims(1)="SawZombieWalk"
     WalkAnims(2)="SawZombieWalk"
     WalkAnims(3)="SawZombieWalk"
     IdleCrouchAnim="SawZombieIdle"
     IdleWeaponAnim="SawZombieIdle"
     IdleRestAnim="SawZombieIdle"
     AmbientSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip_Xmas.ScrakeFrost'
     DrawScale=1.050000
     PrePivot=(Z=3.000000)
     Skins(0)=Texture'DZResPack.scrake_frost_new'
     Skins(1)=TexPanner'KF_Specimens_Trip_T.scrake_saw_panner'
     SoundVolume=175
     SoundRadius=100.000000
     TruePMHeadHeight=2.200000 // Добавлено такое название вместо переменной HeadHeight для АнтиАима
     HeadHeight=200.0 // Специально искажена эта переменная для АнтиАима
     Mass=1000.000000
     RotationRate=(Yaw=45000,Roll=0)
}
