//=============================================================================
// AK47 Pickup.
//=============================================================================
class ID_Weapon_Base_P416_Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=4.000000
     cost=800
     AmmoCost=25
     BuyClipSize=30
     PowerValue=45
     SpeedValue=85
     RangeValue=70
     Description="Advanced tactical assault rifle. Equipped with an aimpoint sight."
     ItemName="P416"
     ItemShortName="P416"
     AmmoItemName="7.62x51mm Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=3
     EquipmentCategoryID=3
     InventoryType=Class'IDRPGMod.ID_Weapon_Base_P416'
     PickupMessage="You got the P416"
     PickupSound=Sound'KF_SCARSnd.SCAR_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'DZResPack.p416_pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
