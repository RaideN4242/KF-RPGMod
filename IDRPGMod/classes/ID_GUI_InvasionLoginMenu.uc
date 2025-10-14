class ID_GUI_InvasionLoginMenu extends KFInvasionLoginMenu;

function bool NotifyLevelChange() // We want to get ride of this menu!
{
	bPersistent = false;
	return true;
}
function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	Super(UT2K4PlayerLoginMenu).InitComponent(MyController, MyComponent);
	c_Main.RemoveTab(Panels[0].Caption);
	c_Main.ActivateTabByName(Panels[1].Caption, true);
}

defaultproperties
{
     Panels(1)=(ClassName="IDRPGMod.ID_GUI_Tab_Skills",Caption="Skills",Hint="View your skills of this server")
     Panels(3)=(ClassName="IDRPGMod.MyKFTab_MidGameHelp",Hint="How to survive in RPG Killing Floor")
     Panels(4)=(ClassName="IDRPGMod.MyKFTab_MidGameRules",Caption="Rules",Hint="Respect rules you bastard!")
}
