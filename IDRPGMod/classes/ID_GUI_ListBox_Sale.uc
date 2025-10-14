class ID_GUI_ListBox_Sale extends KFBuyMenuSaleListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(Class'ID_GUI_List_Sale');
	Super.InitComponent(MyController,MyOwner);
}
function GUIBuyable GetSelectedBuyable()
{
	return ID_GUI_List_Sale(List).GetSelectedBuyable();
}

defaultproperties
{
}
