class ID_Monster_Zombie_Patty_LAWProjectile extends LAWProj;

simulated function PostBeginPlay()
{
	// Difficulty Scaling
	if (Level.Game != none)
	{
		Damage *= 1 + ID_RPG_Base_GameType(Level.Game).GetPlayersNum() * 0.05;
	}

	super.PostBeginPlay();
}

defaultproperties
{
     ArmDistSquared=0.000000
     Damage=150.000000
     MyDamageType=Class'IDRPGMod.ID_Monster_Zombie_Patty_LAWProjectile_DamageType'
}
