class ID_HUD_DrawableActor extends Actor;

var float LivingTime;
var int Speed;

replication
{
	unreliable if (Role == ROLE_Authority)
		LivingTime;
}

simulated event Tick( float DeltaTime )
{
	local vector dvect;
	super.Tick(DeltaTime);
	LivingTime += DeltaTime;
	dvect = vect(0, 0, 0);
	dvect.Z = Speed * DeltaTime;
	Move(dvect);
}

simulated function Draw(ID_HUD HUD, Canvas C, float X, float Y, float Distance, ID_RPG_Base_PlayerController CurrentPlayerController)
{

}

defaultproperties
{
     Speed=150
     DrawType=DT_None
     LifeSpan=1.500000
}
