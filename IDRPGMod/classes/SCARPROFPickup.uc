class SCARPROFPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=20.000000
     cost=350000000
     AmmoCost=50
     BuyClipSize=50
     PowerValue=45
     SpeedValue=85
     RangeValue=70
     Description="Laser rifle. Equipped with an aimpoint sight."
     ItemName="Laser SCAR"
     ItemShortName="Laser SCAR"
     AmmoItemName="7.62x51mm Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=7
     EquipmentCategoryID=3
     InventoryType=Class'IDRPGMod.SCARPROFAssaultRifle'
     PickupMessage="You got the Laser SCAR"
     PickupSound=Sound'KF_SCARSnd.SCAR_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups2_Trip.Rifles.SCAR_Pickup'
     Skins(0)=Texture'DZResPack.ProfScar3rd'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
