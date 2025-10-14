//=============================================================================
// SCAR MK17 Inventory class
//=============================================================================
class ID_Weapon_Base_P416 extends ID_RPG_Base_Weapon
	config(user);

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
     MagCapacity=30
     ReloadRate=2.966000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_SCAR"
     HudImage=Texture'DZResPack.P416Unselect'
     SelectedHudImage=Texture'DZResPack.P416Select'
     Weight=4.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=50.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'DZResPack.P416Trader'
     bIsTier3Weapon=True
     SelectSoundRef="KF_SCARSnd.SCAR_Select"
     PlayerIronSightFOV=65.000000
     ZoomedDisplayFOV=20.000000
     FireModeClass(0)=Class'IDRPGMod.ID_Weapon_Base_P416_Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="An advanced tactical assault rifle. Fires in semi or full auto with great power and accuracy."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=50.000000
     Priority=175
     CustomCrosshair=11
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
     InventoryGroup=4
     GroupOffset=4
     PickupClass=Class'IDRPGMod.ID_Weapon_Base_P416_Pickup'
     PlayerViewOffset=(X=25.000000,Y=20.000000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'IDRPGMod.ID_Weapon_Base_P416_Attachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="P416"
     Mesh=SkeletalMesh'DZResPack.P416_v'
     Skins(0)=Texture'DZResPack.P416body'
     Skins(1)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
     Skins(2)=Texture'DZResPack.P416dotcopy_00_00_00'
     Skins(3)=Texture'DZResPack.P416sight'
     Skins(4)=Texture'DZResPack.P416body'
     Skins(5)=Texture'DZResPack.P416sil'
     TransientSoundVolume=1.250000
}
