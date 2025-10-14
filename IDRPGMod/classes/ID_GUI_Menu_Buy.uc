class ID_GUI_Menu_Buy extends GUIBuyMenu;

function bool NotifyLevelChange()
{
	bPersistent = false;
	return true;
}
function InitTabs()
{
	c_Tabs.AddTab(PanelCaption[0], string(Class'ID_GUI_Tab_BuyMenu'),, PanelHint[0]);
	//c_Tabs.AddTab(PanelCaption[1], string(Class'ID_GUI_Tab_Perks'),, PanelHint[1]);
}

function UpdateHeader()
{
	local int TimeLeft;
	if ( ID_RPG_Base_PlayerController(PlayerOwner()) == none)
		return;
	
	TimeLeft = ID_RPG_Base_HumanPawn(PlayerOwner().Pawn).ShoppingTimeLeft;
	TimeLeftLabel.Caption = "Shopping time ends in" @ TimeLeft;

	if ( TimeLeft < 10 )
		TimeLeftLabel.TextColor = RedColor;
	else
		TimeLeftLabel.TextColor = GreenGreyColor;
}

defaultproperties
{
     HeaderBG_Left=None

     HeaderBG_Center=None

     HeaderBG_Right=None

     CurrentPerkLabel=None

     WaveLabel=None

     HeaderBG_Left_Label=None

     QuickPerkSelect=None

     StoreTabButton=None

     PerkTabButton=None

}
