//=============================================================================
// PTurretPickup.
//=============================================================================
class PTurretPickupM extends KFWeaponPickup;

defaultproperties
{
     Weight=3.000000
     cost=5000
     AmmoCost=5000
     BuyClipSize=1
     PowerValue=100
     SpeedValue=10
     RangeValue=25
     Description="A turret made by the Aperture Science."
     ItemName="Medic Portal Turret"
     ItemShortName="Medic Portal Turret"
     AmmoItemName="Medic Portal Turret"
     CorrespondingPerkIndex=9
     EquipmentCategoryID=3
     InventoryType=Class'IDRPGMod.PTurretM'
     PickupMessage="You got a Medic Portal Turret."
     PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'DZResPack.pickups.PTurretMesh'
     Skins(0)=Texture'DZResPack.Skins.Turret_01_inactive'
     CollisionRadius=22.000000
     CollisionHeight=23.000000
}
