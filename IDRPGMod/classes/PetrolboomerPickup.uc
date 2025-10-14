//=============================================================================
// L85 Pickup.
//=============================================================================
class PetrolboomerPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=20.000000
     cost=200000000
     AmmoCost=30
     BuyClipSize=50
     PowerValue=30
     SpeedValue=100
     RangeValue=40
     Description="A deadly experimental weapon designed by Horzine industries. It can fire streams of burning liquid which ignite on contact."
     ItemName="Petrolboomer"
     ItemShortName="Petrolboomer"
     AmmoItemName="Napalm"
     AmmoMesh=StaticMesh'KillingFloorStatics.FT_AmmoMesh'
     CorrespondingPerkIndex=5
     EquipmentCategoryID=3
     InventoryType=Class'IDRPGMod.Petrolboomer'
     PickupMessage="You got the Petrolboomer"
     PickupSound=Sound'KF_FlamethrowerSnd.FT_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'DZResPack.stc.w_Petrolboomer'
     DrawScale=1.250000
     CollisionRadius=30.000000
     CollisionHeight=5.000000
}
