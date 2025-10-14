class DamTypeNinjaCrossbowPro extends ID_RPG_Base_Weapon_DamageType_Projectile;
/*
 static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if ( KFStatsAndAchievements != none )
	{
		if (Killed.IsA('ZombieHusk'))
		{
			KFStatsAndAchievements.AddHuskAndZedOneShotKill(true, false);
		}
		else
		{
			KFStatsAndAchievements.AddHuskAndZedOneShotKill(false, true);
		}
	}
}
*/

defaultproperties
{
     HeadShotDamageMult=1.000000
     IsMelee=True
     WeaponClass=Class'IDRPGMod.NinjaCrossbowPro'
     bThrowRagdoll=True
     bRagdollBullet=True
     DamageThreshold=1
     KDamageImpulse=7500.000000
     KDeathVel=250.000000
     KDeathUpKick=25.000000
}
