class WTFEquipAFS12a extends ID_Weapon_Base_AA12AS;

defaultproperties
{
     HudImage=Texture'DZResPack.AA12_unselected'
     SelectedHudImage=Texture'DZResPack.AA12'
     TraderInfoTexture=Texture'DZResPack.AFS12_Trader'
     SkinRefs(0)="DZResPack.AFS12.AFS12"
     HudImageRef="DZResPack.AA12_unselected"
     SelectedHudImageRef="DZResPack.AA12"
     FireModeClass(0)=Class'IDRPGMod.WTFEquipAFS12Fire'
     Description="AFS12 with special bullets"
     PickupClass=Class'IDRPGMod.WTFEquipAFS12Pickup'
     AttachmentClass=Class'IDRPGMod.WTFEquipAFS12Attachment'
     ItemName="AFS12 Pro"
     Skins(0)=Texture'DZResPack.AFS12'
     AmbientGlow=25
	 MagCapacity=25
}
