//=============================================================================
// M14EBR Pickup.
//=============================================================================
class M14EBRProPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=20.000000
     cost=700000000
     AmmoCost=5000
     BuyClipSize=20
     Description="Updated M14 Enhanced Battle Rifle - Semi Auto variant. Equipped with a laser sight."
     ItemName="M14 EBR Pro"
     ItemShortName="M14 EBR Pro"
     AmmoItemName="7.62x51mm Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=2
     EquipmentCategoryID=3
     InventoryType=Class'IDRPGMod.M14EBRPro'
     PickupMessage="You got the M14 EBR Pro"
     PickupSound=Sound'KF_M14EBRSnd.M14EBR_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups2_Trip.Rifles.M14_EBR_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
	 Skins(0)=Texture'DZResPack.Weapon_M14.M14_3rd'
}
