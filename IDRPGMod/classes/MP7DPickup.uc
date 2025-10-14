class MP7DPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=20.000000
     cost=350000000
     AmmoCost=10
     BuyClipSize=40
     PowerValue=40
     SpeedValue=95
     RangeValue=45
     Description="Sub machine guns small enough to carry one in each hand."
     ItemName="Dual MP7s"
     ItemShortName="MP7D"
     AmmoItemName="4.6x30mm Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     EquipmentCategoryID=3
     InventoryType=Class'IDRPGMod.MP7Dual'
     PickupMessage="You got Dual MP7s"
     PickupSound=Sound'KF_MP7Snd.MP7_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'DZResPack.MP7D_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
