class ID_GUI_List_PerkSelect extends KFPerkSelectList;

function InitList(KFSteamStatsAndAchievements StatsAndAchievements)
{
	local KFPlayerController KFPC;
	local ID_RPG_Stats_ReplicationLink ST;

	// Grab the Player Controller for later use
	KFPC = KFPlayerController(PlayerOwner());

	// Hold onto our reference
	ST = Class'ID_RPG_Stats_ReplicationLink'.Static.FindStats(PlayerOwner());
	if( ST==None )
		return;

	// Update the ItemCount and select the first item
	ItemCount = 1;
	SetIndex(0);

	PerkName.Remove(0, PerkName.Length);
	PerkLevelString.Remove(0, PerkLevelString.Length);
	PerkProgress.Remove(0, PerkProgress.Length);

	if ( bNotify )
		CheckLinkedObjects(Self);
	if ( MyScrollBar != none )
		MyScrollBar.AlignThumb();
}

function bool PreDraw(Canvas Canvas)
{
	if ( Controller.MouseX >= ClientBounds[0] && Controller.MouseX <= ClientBounds[2] && Controller.MouseY >= ClientBounds[1] )
	{
		//  Figure out which Item we're clicking on
		MouseOverIndex = Top + ((Controller.MouseY - ClientBounds[1]) / ItemHeight);
		if ( MouseOverIndex >= ItemCount )
		{
			MouseOverIndex = -1;
		}
	}
	else
	{
		MouseOverIndex = -1;
	}

	return false;
}

function DrawPerk(Canvas Canvas, int CurIndex, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local float TempX, TempY;
	local float IconSize;
	local float TempWidth, TempHeight;
	local ID_RPG_Stats_ReplicationLink ST;

	ST = Class'ID_RPG_Stats_ReplicationLink'.Static.FindStats(Canvas.Viewport.Actor);
	if( ST==None )
		return;

	// Offset for the Background
	TempX = X;
	TempY = Y + ItemSpacing / 2.0;

	// Initialize the Canvas
	Canvas.Style = 1;
	Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw Item Background
	Canvas.SetPos(TempX, TempY);
	if ( bSelected )
	{
		Canvas.DrawTileStretched(SelectedPerkBackground, IconSize, IconSize);
		Canvas.SetPos(TempX + IconSize - 1.0, Y + 5.0);
		Canvas.DrawTileStretched(SelectedInfoBackground, Width - IconSize, Height - ItemSpacing - 10);
	}
	else
	{
		Canvas.DrawTileStretched(PerkBackground, IconSize, IconSize);
		Canvas.SetPos(TempX + IconSize - 1.0, Y + 5.0);
		Canvas.DrawTileStretched(InfoBackground, Width - IconSize, Height - ItemSpacing - 10);
	}

	// Offset and Calculate Icon's Size
	TempX += ItemBorder * Height;
	TempY += ItemBorder * Height;

	TempX += IconSize + (IconToInfoSpacing * Width);
	TempY += TextTopOffset * Height;

	// Select Text Color
	if ( CurIndex == MouseOverIndex )
		Canvas.SetDrawColor(255, 0, 0, 255);
	else Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw the Perk's Level Name
	Canvas.StrLen("RPG", TempWidth, TempHeight);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawText("RPG");
}

function float SaleItemHeight(Canvas c)
{
	return (MenuOwner.ActualHeight() / 5 - 1);
}

defaultproperties
{
     GetItemHeight=ID_GUI_List_PerkSelect.SaleItemHeight
}
