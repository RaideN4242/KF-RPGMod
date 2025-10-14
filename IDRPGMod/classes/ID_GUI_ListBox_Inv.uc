class ID_GUI_ListBox_Inv extends KFBuyMenuInvListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(Class'ID_GUI_List_Inv');
	Super.InitComponent(MyController,MyOwner);
}
final function GUIBuyable FindMatchingBuyable( Class<Actor> A )
{
	local bool bArmor;
	local int i;

	bArmor = (A==Class'Vest');
	for( i=0; i<List.MyBuyables.Length; ++i )
		if( List.MyBuyables[i]!=None && (List.MyBuyables[i].ItemWeaponClass==A || (bArmor && List.MyBuyables[i].bIsVest)) )
			return List.MyBuyables[i];
	return None;
}

function GUIBuyable GetSelectedBuyable()
{
	if ( List.Index < List.MyBuyables.length && List.MyBuyables[List.Index] != none )
	{	
		return List.MyBuyables[List.Index];
	}
}

defaultproperties
{
}
