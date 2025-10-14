class ID_RPG_Base_Util_DamageAffector extends ID_RPG_Base_Util;

var bool IsDamageToPlayer;

function int GetNewDamage(int Damage, class<DamageType> DamageType)
{
	return Damage;
}

defaultproperties
{
     IsDamageToPlayer=True
}
