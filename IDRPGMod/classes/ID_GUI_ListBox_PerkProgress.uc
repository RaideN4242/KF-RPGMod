class ID_GUI_ListBox_PerkProgress extends KFPerkProgressListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(Class'ID_GUI_List_PerkProgress');
	Super.InitComponent(MyController,MyOwner);
}

defaultproperties
{
}
