class ID_HUD_DrawableActor_Experience extends ID_HUD_DrawableActor;

var string Experience;
var ID_RPG_Base_PlayerController Controller;

replication
{
	reliable if(Role == ROLE_Authority)
		Experience, Controller; 
}

simulated function Draw(ID_HUD HUD, Canvas C, float X, float Y, float Distance, ID_RPG_Base_PlayerController CurrentPlayerController)
{
	local float StringHeight, StringWidth;
	local string ExpString;

	if (Controller != CurrentPlayerController)
	{
		return;
	}
	
	C.Font = HUD.LoadRPGInfoFontStatic(30 - 10 * (Distance / HUD.InfoRadius));
	C.SetDrawColor(35, 255, 35, 255 - LivingTime * 20);
	ExpString = "+" @ Experience @ "Exp";  
	C.StrLen(ExpString, StringWidth, StringHeight);
	C.SetPos(X - StringWidth * 0.5, Y);
	C.DrawText(ExpString);
}

defaultproperties
{
     Speed=70
     NetPriority=4.000000
     LifeSpan=2.500000
}
