class ID_Weapon_Base_M32GL extends ID_RPG_Base_Weapon_Shotgun
	abstract;

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

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

defaultproperties
{
     MagCapacity=6
     ReloadRate=1.200000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_M32_MGL"
     HudImage=Texture'KillingFloor2HUD.WeaponSelect.M32_unselected'
     SelectedHudImage=Texture'KillingFloor2HUD.WeaponSelect.M32'
     Weight=7.000000
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     SleeveNum=2
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M32'
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=40.000000
     FireModeClass(0)=Class'IDRPGMod.ID_Weapon_Base_M32GL_Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'KF_M79Snd.M79_Select'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.650000
     CurrentRating=0.650000
     Description="An advanced semi automatic grenade launcher. Launches high explosive grenades."
     DisplayFOV=65.000000
     Priority=20
     InventoryGroup=3
     GroupOffset=6
     PickupClass=Class'IDRPGMod.ID_Weapon_Base_M32GL_Pickup'
     PlayerViewOffset=(X=18.000000,Y=20.000000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.M32Attachment'
     IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
     ItemName="M32GL"
     LightType=LT_None
     LightBrightness=0.000000
     LightRadius=0.000000
     Mesh=SkeletalMesh'KF_Weapons2_Trip.M32_MGL_Trip'
     Skins(0)=Combiner'KF_Weapons2_Trip_T.Special.M32_cmb'
     Skins(1)=Shader'KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr'
}
