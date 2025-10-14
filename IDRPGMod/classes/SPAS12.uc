class SPAS12 extends ID_RPG_Base_Weapon;
/*
#exec OBJ LOAD FILE="Spas12_A.ukx" PACKAGE=ServerPerksPv1
#exec Texture Import File=SPAS12_selected.dds
#exec Texture Import File=SPAS12_Trader.dds
#exec Texture Import File=SPAS12_Unselected.dds
#exec Texture Import File=wpn_gilza1.dds
#exec Texture Import File=wpn_spas12.dds
*/
var LaserDot Spot;					  // The first person laser site dot
var() float SpotProjectorPullback;	 // Amount to pull back the laser dot projector from the hit location
var bool bLaserActive;			  // The laser site is active
var SPAS12LaserBeamEffect Beam;					  // Third person laser beam effect

var() class<InventoryAttachment> LaserAttachmentClass;	 // First person laser attachment class
var Actor LaserAttachment;		  // First person laser attachment

var() float AmmoRegenRate;
var() int HealBoostAmount;
Const MaxAmmoCount=500;
var int HealAmmoCharge;
var float RegenTimer;
var localized string SuccessfulHealMessage;
/* replication
{
	reliable if(Role < ROLE_Authority)
		ServerChangeFireMode,ServerSetLaserActive;
}*/ // для патча 1054

replication
{
 	reliable if( Role == ROLE_Authority )
		HealAmmoCharge,ClientSuccessfulHeal;
}

simulated function ClientSuccessfulHeal(String HealedName)
{
	if( PlayerController(Instigator.Controller) != none )
	{
		PlayerController(Instigator.controller).ClientMessage(SuccessfulHealMessage@HealedName, 'CriticalEvent');
	}
}

simulated function float ChargeBar()
{
	return FClamp(float(HealAmmoCharge)/float(MaxAmmoCount),0,1);
}

simulated function MaxOutAmmo()
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = MaxAmmo(0);
		return;
	}
	if ( Ammo[0] != None )
		Ammo[0].AmmoAmount = Ammo[0].MaxAmmo;

	HealAmmoCharge = MaxAmmoCount;
}

simulated function SuperMaxOutAmmo()
{
   HealAmmoCharge = 999;

	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = 999;
		return;
	}
	if ( Ammo[0] != None )
		Ammo[0].AmmoAmount = 999;
}

simulated function int MaxAmmo(int mode)
{
	if( Mode == 1 )
	{
	  return MaxAmmoCount;
	}
	else
	{
	  return super.MaxAmmo(mode);
	}
}

simulated function FillToInitialAmmo()
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = Max(AmmoCharge[0], AmmoClass[0].Default.InitialAmount);
		HealAmmoCharge = MaxAmmoCount;
		return;
	}

	if ( Ammo[0] != None )
		Ammo[0].AmmoAmount = Ammo[0].AmmoAmount;

	HealAmmoCharge = MaxAmmoCount;
}

simulated function int AmmoAmount(int mode)
{
	if( Mode == 1 )
	{
	  return HealAmmoCharge;
	}
	else
	{
	  return super.AmmoAmount(mode);
	}
}

simulated function bool AmmoMaxed(int mode)
{
	if( Mode == 1 )
	{
	  return HealAmmoCharge>=MaxAmmoCount;
	}
	else
	{
	  return super.AmmoMaxed(mode);
	}
}

simulated function float AmmoStatus(optional int Mode) // returns float value for ammo amount
{
	if( Mode == 1 )
	{
	  return float(HealAmmoCharge)/float(MaxAmmoCount);
	}
	else
	{
	  return super.AmmoStatus(Mode);
	}
}

simulated function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
	if( Mode == 1 )
	{
		if( Load>HealAmmoCharge )
		{
			return false;
		}

		HealAmmoCharge-=Load;
		Return True;
	}
	else
	{
	  return super.ConsumeAmmo(Mode, load, bAmountNeededIsMax);
	}
}

function bool AddAmmo(int AmmoToAdd, int Mode)
{
	if( Mode == 1 )
	{
		if( HealAmmoCharge<MaxAmmoCount )
		{
			HealAmmoCharge+=AmmoToAdd;
			if( HealAmmoCharge>MaxAmmoCount )
			{
				HealAmmoCharge = MaxAmmoCount;
			}
		}
		return true;
	}
	else
	{
		return super.AddAmmo(AmmoToAdd,Mode);
	}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		if (Beam == None)
		{
			Beam = Spawn(class'SPAS12LaserBeamEffect');
		}
	}
}

simulated function Destroyed()
{
	if (Spot != None)
		Spot.Destroy();

	if (Beam != None)
		Beam.Destroy();

	if (LaserAttachment != None)
		LaserAttachment.Destroy();

	super.Destroyed();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if (Role == ROLE_Authority)
	{
		if (Beam == None)
		{
			Beam = Spawn(class'SPAS12LaserBeamEffect');
		}
	}

	if (bLaserActive)
		TurnOnLaser();
}

simulated function DetachFromPawn(Pawn P)
{
	TurnOffLaser();

	Super.DetachFromPawn(P);

	if (Beam != None)
	{
		Beam.Destroy();
	}
}

simulated function bool PutDown()
{
	if (Beam != None)
	{
		Beam.Destroy();
	}

	TurnOffLaser(true); 

	return super.PutDown();
}
/*
// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
	if(ReadyToFire(0))
	{
		DoToggle();
		ToggleLaser();
	}
}
*/
// Toggle the laser on and off
simulated function ToggleLaser()
{
	if( Instigator.IsLocallyControlled() )
	{
		if( Role < ROLE_Authority  )
		{
			ServerSetLaserActive(!bLaserActive);
		}

		bLaserActive = !bLaserActive;

		if( Beam != none )
		{
			Beam.SetActive(bLaserActive);
		}

		if( bLaserActive )
		{
			if ( LaserAttachment == none )
			{
				LaserAttachment = Spawn(LaserAttachmentClass,,,,);
				AttachToBone(LaserAttachment,'LightBone');
			}
			LaserAttachment.bHidden = false;

			if (Spot == None)
			{
				Spot = Spawn(class'LaserDot', self);
			}
		}
		else
		{
			LaserAttachment.bHidden = true;
			if (Spot != None)
			{
				Spot.Destroy();
			}
		}
	}
}
//--------------------------------------------------------------------------------------------------
// TurnOnLaser
simulated function TurnOnLaser()
{
	if( Instigator.IsLocallyControlled() )
	{
		if( Role < ROLE_Authority  )
		{
			ServerSetLaserActive(true);
		}

		bLaserActive = true;

		if( Beam != none )
		{
			Beam.SetActive(true);
		}

		if ( LaserAttachment == none )
		{
			LaserAttachment = Spawn(LaserAttachmentClass,,,,);
			AttachToBone(LaserAttachment,'LightBone');
		}
		LaserAttachment.bHidden = false;
		if (Spot == None)
		{
			Spot = Spawn(class'LaserDot', self);
		}
	}
}
//--------------------------------------------------------------------------------------------------
simulated function TurnOffLaser(optional bool bPutDown)
{
	if( Instigator.IsLocallyControlled() )
	{
		if( Role < ROLE_Authority  )
		{
			ServerSetLaserActive(false);
		}

		if (!bPutDown)
			bLaserActive = false;
		LaserAttachment.bHidden = true;

		if( Beam != none )
		{
			Beam.SetActive(false);
		}

		if (Spot != None)
		{
			Spot.Destroy();
		}
	}
}

// Set the new fire mode on the server
function ServerSetLaserActive(bool bNewWaitForRelease)
{
	if( Beam != none )
	{
		Beam.SetActive(bNewWaitForRelease);
	}

	if( bNewWaitForRelease )
	{
		bLaserActive = true;
		if (Spot == None)
		{
			Spot = Spawn(class'LaserDot', self);
		}
	}
	else
	{
		bLaserActive = false;
		if (Spot != None)
		{
			Spot.Destroy();
		}
	}
}

simulated event RenderOverlays( Canvas Canvas )
{
	local int m;
	local Vector StartTrace, EndTrace;
	local Vector HitLocation, HitNormal;
	local Actor Other;
	local vector X,Y,Z;
	local coords C;

	if (Instigator == None)
		return;

	if ( Instigator.Controller != None )
		Hand = Instigator.Controller.Handedness;

	if ((Hand < -1.0) || (Hand > 1.0))
		return;

	// draw muzzleflashes/smoke for all fire modes so idle state won't
	// cause emitters to just disappear
	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (FireMode[m] != None)
		{
			FireMode[m].DrawMuzzleFlash(Canvas);
		}
	}

	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
	SetRotation( Instigator.GetViewRotation() + ZoomRotInterp);

	// Handle drawing the laser beam dot
	if (Spot != None)
	{
		StartTrace = Instigator.Location + Instigator.EyePosition();
		GetViewAxes(X, Y, Z);

		if( bIsReloading && Instigator.IsLocallyControlled() )
		{
			C = GetBoneCoords('LightBone');
			X = C.XAxis;
			Y = C.YAxis;
			Z = C.ZAxis;
		}

		EndTrace = StartTrace + 65535 * X;

		Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (Other != None && Other != Instigator && Other.Base != Instigator )
		{
			EndBeamEffect = HitLocation;
		}
		else
		{
			EndBeamEffect = EndTrace;
		}

		Spot.SetLocation(EndBeamEffect - X*SpotProjectorPullback);

		if(  Pawn(Other) != none )
		{
			Spot.SetRotation(Rotator(X));
			Spot.SetDrawScale(Spot.default.DrawScale * 0.5);
		}
		else if( HitNormal == vect(0,0,0) )
		{
			Spot.SetRotation(Rotator(-X));
			Spot.SetDrawScale(Spot.default.DrawScale);
		}
		else
		{
			Spot.SetRotation(Rotator(-HitNormal));
			Spot.SetDrawScale(Spot.default.DrawScale);
		}
	}

	//PreDrawFPWeapon();	// Laurent -- Hook to override things before render (like rotation if using a staticmesh)

	bDrawingFirstPerson = true;
	Canvas.DrawActor(self, false, false, DisplayFOV);
	bDrawingFirstPerson = false;
}

function bool RecommendRangedAttack()
{
	return true;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}
/*
exec function SwitchModes()
{
	DoToggle();
}
*/
function float GetAIRating()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return AIRating;
}

function byte BestMode()
{
	return 0;
}

simulated function SetZoomBlendColor(Canvas c)
{
	local Byte	val;
	local Color   clr;
	local Color   fog;

	clr.R = 255;
	clr.G = 255;
	clr.B = 255;
	clr.A = 255;

	if( Instigator.Region.Zone.bDistanceFog )
	{
		fog = Instigator.Region.Zone.DistanceFogColor;
		val = 0;
		val = Max( val, fog.R);
		val = Max( val, fog.G);
		val = Max( val, fog.B);
		if( val > 128 )
		{
			val -= 128;
			clr.R -= val;
			clr.G -= val;
			clr.B -= val;
		}
	}
	c.DrawColor = clr;
}

simulated function Tick(float dt)
{
	local float rrate;
	if ( Level.NetMode!=NM_Client && HealAmmoCharge<MaxAmmoCount && RegenTimer<Level.TimeSeconds )
	{
		RegenTimer = Level.TimeSeconds + AmmoRegenRate;

		if ( ID_RPG_Base_HumanPawn(Instigator) != none )
		{
			rrate = 10;
			rrate *= 1 + class'ID_Skill_BattleMedic'.static.GetSyringeRechrgeRateMulti(ID_RPG_Base_HumanPawn(Instigator));
			HealAmmoCharge += rrate;
		}
		else
		{
			HealAmmoCharge += 10;
		}

		if ( HealAmmoCharge > MaxAmmoCount )
		{
			HealAmmoCharge = MaxAmmoCount;
		}
	}
}

// Overridden to not take us out of ironsights when firing
simulated function WeaponTick(float dt)
{
//	local float LastSeenSeconds,ReloadMulti;
	local Vector StartTrace, EndTrace, X,Y,Z;
	local Vector HitLocation, HitNormal;
	local Actor Other;
	local vector MyEndBeamEffect;
	local coords C;

	super.WeaponTick(dt);

	if ( (Level.NetMode == NM_Client) || Instigator == None || KFFriendlyAI(Instigator.Controller) == none && Instigator.PlayerReplicationInfo == None)
		return;
/*
	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if(!bIsReloading)
	{
		if(!Instigator.IsHumanControlled())
		{
			LastSeenSeconds = Level.TimeSeconds - Instigator.Controller.LastSeenTime;
			if(MagAmmoRemaining == 0 || ((LastSeenSeconds >= 5 || LastSeenSeconds > MagAmmoRemaining) && MagAmmoRemaining < MagCapacity))
				ReloadMeNow();
		}
	}
	else
	{
		if((Level.TimeSeconds - ReloadTimer) >= ReloadRate)
		{
			if(AmmoAmount(0) <= MagCapacity && !bHoldToReload)
			{
				MagAmmoRemaining = AmmoAmount(0);
				ActuallyFinishReloading();
			}
			else
			{
				if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
				{
					ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
				}
				else
				{
					ReloadMulti = 1.0;
				}

				AddReloadedAmmo();

				if( bHoldToReload )
				{
					NumLoadedThisReload++;
				}

				if(MagAmmoRemaining < MagCapacity && MagAmmoRemaining < AmmoAmount(0) && bHoldToReload)
					ReloadTimer = Level.TimeSeconds;
				if(MagAmmoRemaining >= MagCapacity || MagAmmoRemaining >= AmmoAmount(0) || !bHoldToReload || bDoSingleReload)
					ActuallyFinishReloading();
				else if( Level.NetMode!=NM_Client )
					Instigator.SetAnimAction(WeaponReloadAnim);
			}
		}
		else if(bIsReloading && !bReloadEffectDone && Level.TimeSeconds - ReloadTimer >= ReloadRate / 2)
		{
			bReloadEffectDone = true;
			ClientReloadEffects();
		}
	}
*/
	if( Role == ROLE_Authority && Beam != none )
	{
		if( bIsReloading && WeaponAttachment(ThirdPersonActor) != none )
		{
			C = WeaponAttachment(ThirdPersonActor).GetBoneCoords('LightBone');
			X = C.XAxis;
			Y = C.YAxis;
			Z = C.ZAxis;
		}
		else
		{
			GetViewAxes(X,Y,Z);
		}

		// the to-hit trace always starts right in front of the eye
		StartTrace = Instigator.Location + Instigator.EyePosition() + X*Instigator.CollisionRadius;

		EndTrace = StartTrace + 65535 * X;

		Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (Other != None && Other != Instigator && Other.Base != Instigator )
		{
			MyEndBeamEffect = HitLocation;
		}
		else
		{
			MyEndBeamEffect = EndTrace;
		}

		Beam.EndBeamEffect = MyEndBeamEffect;
		Beam.EffectHitNormal = HitNormal;
	}
}

// Copied from KFWeaponShotgun to support Achievements
simulated function AddReloadedAmmo()
{
	if(AmmoAmount(0) > 0)
		++MagAmmoRemaining;

	// Don't do this on a "Hold to reload" weapon, as it can update too quick actually and cause issues maybe - Ramm
	if( !bHoldToReload )
	{
		ClientForceKFAmmoUpdate(MagAmmoRemaining,AmmoAmount(0));
	}

	if ( PlayerController(Instigator.Controller) != none && KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements) != none )
	{
		KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements).OnBenelliReloaded();
	}
}

defaultproperties
{
     SpotProjectorPullback=1.000000
     LaserAttachmentClass=Class'KFMod.LaserAttachmentFirstPerson'
     AmmoRegenRate=0.300000
     HealBoostAmount=100
     HealAmmoCharge=500
     SuccessfulHealMessage="You welded "
     MagCapacity=30
     ReloadRate=0.083000
     ReloadAnim="Reload"
     ReloadAnimRate=2.500000
     bHoldToReload=True
     WeaponReloadAnim="Reload_Shotgun"
     HudImage=Texture'DZResPack.SPAS12_Unselected'
     SelectedHudImage=Texture'DZResPack.SPAS12_selected'
     Weight=20.000000
     bHasAimingMode=True
     IdleAimAnim="Iron_Idle"
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'DZResPack.SPAS12_Trader'
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=40.000000
     FireModeClass(0)=Class'IDRPGMod.SPAS12Fire'
     FireModeClass(1)=Class'IDRPGMod.SPAS12AltFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'SPAS12_Snd.Spas12_Select'
     AIRating=0.600000
     CurrentRating=0.600000
     bShowChargingBar=True
     Description="A military tactical shotgun with semi automatic fire capability. Holds up to 8 shells. "
     DisplayFOV=65.000000
     Priority=180
     InventoryGroup=3
     GroupOffset=9
     PickupClass=Class'IDRPGMod.SPAS12Pickup'
     PlayerViewOffset=(X=15.000000,Y=16.000000,Z=-6.000000)
     BobDamping=5.000000
     AttachmentClass=Class'IDRPGMod.SPAS12Attachment'
     IconCoords=(X1=169,Y1=172,X2=245,Y2=208)
     ItemName="SPAS-12"
     Mesh=SkeletalMesh'DZResPack.Spas12mesh'
     DrawScale=3.000000
     Skins(0)=Texture'DZResPack.wpn_spas12'
     Skins(1)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
     Skins(2)=Texture'DZResPack.wpn_gilza1'
     TransientSoundVolume=1.000000
}
