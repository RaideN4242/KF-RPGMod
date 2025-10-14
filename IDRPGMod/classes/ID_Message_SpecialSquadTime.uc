class ID_Message_SpecialSquadTime extends ID_RPG_Base_Message_Special;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	return class<ID_RPG_Base_Monster>(OptionalObject).default.MenuName @ Default.Message;
}

static function RenderComplexMessage(
	Canvas Canvas,
	out float XL,
	out float YL,
	optional string MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local int i;
	local float TempY;

	i = InStr(MessageString, "|");

	TempY = Canvas.CurY;
	Canvas.Font = class'ID_HUD'.static.LoadRPGInfoFontStatic(25);
	Canvas.FontScaleX = Canvas.ClipX / 1280.0;
	Canvas.FontScaleY = Canvas.ClipY / 1024.0;

	if ( i < 0 )
	{
		Canvas.TextSize(MessageString, XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY);
		Canvas.DrawTextClipped(MessageString, false);
	}
	else
	{
		Canvas.TextSize(Left(MessageString, i), XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY);
		Canvas.DrawTextClipped(Left(MessageString, i), false);

		Canvas.TextSize(Mid(MessageString, i + 1), XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY + YL);
		Canvas.DrawTextClipped(Mid(MessageString, i + 1), false);
	}

	Canvas.FontScaleX = 1.0;
	Canvas.FontScaleY = 1.0;
}

defaultproperties
{
     Message="Time|Prepare your ass!"
     bComplexString=True
     bIsPartiallyUnique=True
     bIsConsoleMessage=False
     Lifetime=8
     DrawColor=(B=50,G=50)
     StackMode=SM_None
     PosY=0.250000
}
