class MolotovClusterBomblet extends Nade;

//only blow up from fuse running out or siren scream
function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	if ( Monster(instigatedBy) != none || instigatedBy == Instigator )
	{
		if( damageType == class'SirenScreamDamage')
		{
			Disintegrate(HitLocation, vect(0,0,1));
		}
	}
}

defaultproperties
{
     Speed=600.000000
     MaxSpeed=600.000000
     MomentumTransfer=100.000000
     MyDamageType=Class'IDRPGMod.ID_Weapon_Base_FlameThrower_DamageType'
     DrawScale=1.000000
}
