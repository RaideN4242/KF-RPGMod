class M4A4HowlDT extends ID_RPG_Base_Weapon
	config(user);

#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax

var() name ReloadShortAnim;
var() float ReloadShortRate;

var() array<name> CheckGunAnims;
var() name CheckGunAnim;
var() float CheckGunAnimRate;

exec function ReloadMeNow()
{
	local float ReloadMulti;
	local int AnimToPlay;
	
	if ( !bIsReloading )
	{
		if(CheckGunAnims.length > 0)
		{
			if ( bHasAimingMode && bAimingRifle )
			{
				ZoomOut(false);
				if( Role < ROLE_Authority)
					ServerZoomOut(false);
			}
			AnimToPlay = rand(CheckGunAnims.length);
			CheckGunAnim = CheckGunAnims[AnimToPlay];
			PlayAnim(CheckGunAnim, CheckGunAnimRate, 0.1);
		}
	}
	if(!AllowReload())
	{	
		return;
	}
	if ( bHasAimingMode && bAimingRifle )
	{
		FireMode[1].bIsFiring = False;

		ZoomOut(false);
		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}
	ReloadMulti = 1.0;
	if ( ID_RPG_Base_HumanPawn(Instigator) != none)
	{
		ReloadMulti +=  class'ID_Skill_ReloadSpeed'.static.GetReloadSpeedMulti(ID_RPG_Base_HumanPawn(Instigator), self); 
	}
	bIsReloading = true;
	ReloadTimer = Level.TimeSeconds;
	if (MagAmmoRemaining <= 0)
	{
		ReloadRate = Default.ReloadRate / ReloadMulti;
	}
	else if (MagAmmoRemaining >= 1)
	{
		ReloadRate = Default.ReloadShortRate / ReloadMulti;
	}
	if( bHoldToReload )
	{
		NumLoadedThisReload = 0;
	}
	ClientReload();
	Instigator.SetAnimAction(WeaponReloadAnim);
	if ( Level.Game.NumPlayers > 1 && KFGameType(Level.Game).bWaveInProgress && KFPlayerController(Instigator.Controller) != none &&
		Level.TimeSeconds - KFPlayerController(Instigator.Controller).LastReloadMessageTime > KFPlayerController(Instigator.Controller).ReloadMessageDelay )
	{
		KFPlayerController(Instigator.Controller).Speech('AUTO', 2, "");
		KFPlayerController(Instigator.Controller).LastReloadMessageTime = Level.TimeSeconds;
	}
}

simulated function ClientReload()
{
	local float ReloadMulti;
	if ( bHasAimingMode && bAimingRifle )
	{
		FireMode[1].bIsFiring = False;

		ZoomOut(false);
		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}
	ReloadMulti = 1.0;
	if ( ID_RPG_Base_HumanPawn(Instigator) != none)
	{
		ReloadMulti +=  class'ID_Skill_ReloadSpeed'.static.GetReloadSpeedMulti(ID_RPG_Base_HumanPawn(Instigator), self); 
	}
	bIsReloading = true;
	if (MagAmmoRemaining <= 0)
	{
		PlayAnim(ReloadAnim, ReloadAnimRate*ReloadMulti, 0.1);
	}
	else if (MagAmmoRemaining >= 1)
	{
		PlayAnim(ReloadShortAnim, ReloadAnimRate*ReloadMulti, 0.1);
	}
}

// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
	if(ReadyToFire(0))
	{
		DoToggle();
	}
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

exec function SwitchModes()
{
	DoToggle();
}

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

defaultproperties
{
     ReloadShortAnim="Reload"
     ReloadShortRate=2.333300
     CheckGunAnims(0)="GunCheck1"
     CheckGunAnims(1)="GunCheck1"
     CheckGunAnims(2)="GunCheck1"
     CheckGunAnims(3)="GunCheck1"
     CheckGunAnim="GunCheck1"
     CheckGunAnimRate=1.000000
     MagCapacity=30
     ReloadRate=2.333300
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_M4"
     HudImage=Texture'DZResPack.M4A4HowlDT_T.csgoM4A4Howl_Unselected'
     SelectedHudImage=Texture'DZResPack.M4A4HowlDT_T.csgoM4A4Howl_Selected'
     Weight=6.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=60.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'DZResPack.M4A4HowlDT_T.csgoM4A4Howl_Trader'
     bIsTier2Weapon=True
     SelectSoundRef="KF_M4RifleSnd.WEP_M4_Foley_Select"
     PlayerIronSightFOV=65.000000
     ZoomedDisplayFOV=45.000000
     FireModeClass(0)=Class'IDRPGMod.M4A4HowlDTFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     BringUpTime=1.000000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="A compact assault rifle. Can be fired in semi or full auto with good damage and good accuracy."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=60.000000
     Priority=130
     CustomCrosshair=11
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
     InventoryGroup=3
     GroupOffset=10
     PickupClass=Class'IDRPGMod.M4A4HowlDTPickup'
     PlayerViewOffset=(X=25.000000,Y=18.000000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'IDRPGMod.M4A4HowlDTAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="M4A4 Howl"
     Mesh=SkeletalMesh'DZResPack.M4A4HowlDT_Mesh'
     Skins(0)=Combiner'DZResPack.M4A4HowlDT_T.m4a4DT_tex_cmb'
     TransientSoundVolume=1.250000
}
