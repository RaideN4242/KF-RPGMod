class ID_GUI_ListBox_PerkSelect extends KFPerkSelectListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(Class'ID_GUI_List_PerkSelect');
	Super.InitComponent(MyController,MyOwner);
}

defaultproperties
{
}
