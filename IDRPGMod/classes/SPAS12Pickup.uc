class SPAS12Pickup extends KFWeaponPickup;
/*
#exec OBJ LOAD FILE="SPAS12_sm.usx" PACKAGE=ServerPerksPv1
#exec Texture Import File=wpn_spas12.dds
#exec Texture Import File=wpn_spas12_1.dds

function bool CheckCanCarry(KFHumanPawn Hm)
{
  local KFPlayerReplicationInfo KFPRI;
  KFPRI = KFPlayerReplicationInfo(Hm.PlayerReplicationInfo);
  if (KFPRI != none)
   {
	if (KFPRI.ClientVeteranSkill == Class'SRVetSupportSpec' && KFPRI.ClientVeteranSkillLevel >= 0 )
	  return Super.CheckCanCarry(Hm);
   }
  return false;
}
*/

defaultproperties
{
     Weight=20.000000
     cost=350000000
     BuyClipSize=6
     PowerValue=70
     SpeedValue=60
     RangeValue=15
     Description="A military tactical shotgun with semi automatic fire capability. Holds up to 6 shells. "
     ItemName="SPAS-12 Shotgun"
     ItemShortName="SPAS-12"
     AmmoItemName="12-gauge shells"
     CorrespondingPerkIndex=1
     EquipmentCategoryID=2
     InventoryType=Class'IDRPGMod.SPAS12'
     PickupMessage="You got the SPAS-12 shotgun."
     PickupSound=Sound'SPAS12_Snd.Spas12_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'DZResPack.spas12_ST'
     Skins(0)=Texture'DZResPack.wpn_spas12'
     Skins(1)=Texture'DZResPack.wpn_spas12_1'
     CollisionRadius=35.000000
     CollisionHeight=5.000000
}
