class ID_Message_ShoppingTime extends ID_RPG_Base_Message_Special;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	return class'KFGameType'.static.ParseLoadingHintNoColor( Default.Message, PlayerController(OptionalObject));
}

static function ClientReceive(PlayerController P, optional int SwitchX, optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	Super.ClientReceive(P,,,,P);
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
	Canvas.Font = class'ID_HUD'.static.LoadRPGInfoFontStatic(30);
	Canvas.FontScaleX = Canvas.ClipX / 1024.0;
	Canvas.FontScaleY = Canvas.FontScaleX;

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
     Message="SHOPPING TIME!|Press %ToggleFlashlight% to shop."
     bComplexString=True
     bIsUnique=True
     bIsConsoleMessage=False
     Lifetime=13
     DrawColor=(B=30)
     StackMode=SM_None
     PosY=0.550000
     FontSize=2
}
