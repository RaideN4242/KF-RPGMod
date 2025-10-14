//=============================================================================
// PTurretPickup.
//=============================================================================
class SentryGunWYDTPickup extends KFWeaponPickup;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	TweenAnim('Fold',0.01f);
}

defaultproperties
{
     Weight=255.000000
     cost=350000000
     AmmoCost=350000000
     BuyClipSize=1
     PowerValue=10000
     SpeedValue=10
     RangeValue=35
     Description="A turret made by the Weyland-Yutani Corporation."
     ItemName="Wey-Y Turret"
     ItemShortName="Wey-Y Turret"
     AmmoItemName="Wey-Yutani Turret"
     CorrespondingPerkIndex=3
     EquipmentCategoryID=3
     InventoryType=Class'IDRPGMod.SentryGunWYDTWeap'
     PickupMessage="You got a Sentry bot."
     PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
     PickupForce="AssaultRiflePickup"
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'DZResPack.SentryGunWYDT_Mesh'
     PrePivot=(Z=1.000000)
     Skins(0)=Shader'DZResPack.SentryGunDTWY_T.SentryGunWY_DT_sh'
     CollisionRadius=22.000000
     CollisionHeight=23.000000
}
