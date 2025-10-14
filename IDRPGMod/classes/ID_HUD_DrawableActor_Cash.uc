class ID_HUD_DrawableActor_Cash extends ID_HUD_DrawableActor;

var int Cash;
var ID_RPG_Base_PlayerController Controller;

replication
{
	reliable if(Role == ROLE_Authority)
		Cash, Controller; 
}

simulated function Draw(ID_HUD HUD, Canvas C, float X, float Y, float Distance, ID_RPG_Base_PlayerController CurrentPlayerController)
{
	local float StringHeight, StringWidth;
	local string CashString;

	if (Controller != CurrentPlayerController)
	{
		return;
	}
	
	C.Font = HUD.LoadRPGInfoFontStatic(30 - 10 * (Distance / HUD.InfoRadius));
	C.SetDrawColor(255, 224, 25, 255 - LivingTime * 20);
	CashString = "+" @ Cash @ "$";
	C.StrLen(CashString, StringWidth, StringHeight);
	C.SetPos(X - StringWidth * 0.5, Y);
	C.DrawText(CashString);
}

defaultproperties
{
     Speed=90
     NetPriority=4.000000
     LifeSpan=2.500000
}
