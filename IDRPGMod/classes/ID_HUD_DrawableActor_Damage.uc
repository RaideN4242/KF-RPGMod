class ID_HUD_DrawableActor_Damage extends ID_HUD_DrawableActor;

var int Damage;

replication
{
	reliable if(Role == ROLE_Authority)
		Damage; 
}

simulated function Draw(ID_HUD HUD, Canvas C, float X, float Y, float Distance, ID_RPG_Base_PlayerController CurrentPlayerController)
{
	local float StringHeight, StringWidth;
	local string DamageString;

	C.Font = HUD.LoadRPGInfoFontStatic(18 - 8 * (Distance / HUD.InfoRadius));
	DamageString = string(Damage);
	C.SetDrawColor(56, 248, 255, 255 - LivingTime * 140);
	
	if (Damage > 15000)
	{
		C.Font = HUD.LoadRPGInfoFontStatic(27 - 10 * (Distance / HUD.InfoRadius));
		C.SetDrawColor(255, 30, 30, 255 - LivingTime * 100);
	}
	
	C.StrLen(DamageString, StringWidth, StringHeight);
	C.SetPos(X - StringWidth * 0.5, Y);
	C.DrawText(DamageString);
}

defaultproperties
{
     Speed=120
     LifeSpan=1.000000
}
