class NinjaCrossbowPro extends ID_RPG_Base_Weapon;

var float Range;
var float LastRangingTime;

var bool bInPose;
var ()	 float	  RotateRate;
var		float	  RegenTimer;	// Tracks regeneration
var rotator Gearrot1;
var rotator Gearrot2;
var rotator Bladerot;

var() sound ZoomSound;
var bool bArrowRemoved;

simulated function WeaponTick(float dt)
{
	super.WeaponTick(dt);

	if ( Level.NetMode!=NM_DedicatedServer && RegenTimer<Level.TimeSeconds )
	{
		RegenTimer = Level.TimeSeconds + 0.008;
		Gearrot1.Yaw += RotateRate;
		SetBoneRotation('Gear1',Gearrot1,1.0);
		Gearrot2.Yaw -= RotateRate;
		SetBoneRotation('Gear2',Gearrot2,1.0);

		if( FireMode[0].NextFireTime <= Level.TimeSeconds )
		{
			Bladerot.Yaw -= RotateRate;
			SetBoneRotation('Blade',Bladerot,1.0);
		}
 	}

//	if( ForceZoomOutTime > 0 )
//	{
//		if( bAimingRifle )
//		{
//			if( Level.TimeSeconds - ForceZoomOutTime > 0 )
//			{
//				ForceZoomOutTime = 0;
//
//				ZoomOut(false);
//
//				if( Role < ROLE_Authority)
//					ServerZoomOut(false);
//			}
//		}
//		else
//		{
//			ForceZoomOutTime = 0;
//		}
//	}
}

// Force the weapon out of iron sights shortly after firing so reloading looks right
simulated function bool StartFire(int Mode)
{
	if ( super.StartFire(Mode) )
	{
		//ForceZoomOutTime = Level.TimeSeconds + 0.4;

		if ( Instigator != none && PlayerController(Instigator.Controller) != none &&
			 KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements) != none )
		{
			KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements).OneShotBuzzOrM99();
		}

		return true;
	}

	return false;
}

function float GetAIRating()
{
	local AIController B;

	B = AIController(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

simulated function bool CanZoomNow()
{
	return (!FireMode[0].bIsFiring);
}

defaultproperties
{
     bInPose=True
     RotateRate=5000.000000
     ForceZoomOutOnFireTime=0.400000
     MagCapacity=1
     ReloadRate=0.010000
     WeaponReloadAnim="Reload_Cheetah"
     Weight=20.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=65.000000
     SleeveNum=2
     TraderInfoTexture=Texture'DZResPack.NC_Shop'
     bIsTier3Weapon=True
     MeshRef="DZResPack.NinjaCrossbow"
     SelectSoundRef="KF_XbowSnd.Xbow_Select"
     HudImageRef="DZResPack.NC_Shop"
     SelectedHudImageRef="DZResPack.NC_Selected"
     PlayerIronSightFOV=65.000000
     ZoomedDisplayFOV=45.000000
     FireModeClass(0)=Class'IDRPGMod.NinjaCrossbowProFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.650000
     CurrentRating=0.650000
     Description="Ninja Crossbow Pro"
     DisplayFOV=65.000000
     Priority=175
     CustomCrosshair=11
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
     InventoryGroup=4
     GroupOffset=15
     PickupClass=Class'IDRPGMod.NinjaCrossbowProPickup'
     PlayerViewOffset=(X=20.000000,Y=18.000000,Z=-8.000000)
     BobDamping=6.000000
     AttachmentClass=Class'IDRPGMod.NinjaCrossbowAttachment'
     IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
     ItemName="Ninja Crossbow Pro"
     LightType=LT_None
     LightBrightness=0.000000
     LightRadius=0.000000
     Skins(0)=Combiner'DZResPack.star_cmb2'
     Skins(1)=Shader'KF_IJC_Halloween_Weapons2.SeekerSix.Seeker_Sight_Shader'
     Skins(2)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
     Skins(3)=Texture'DZResPack.Tex_0013_1'
     Skins(4)=Combiner'DZResPack.Box_CMB'
}
