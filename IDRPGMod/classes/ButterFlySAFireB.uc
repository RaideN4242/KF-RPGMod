class ButterFlySAFireB extends ID_RPG_Base_Weapon_Melee_Fire;

var() array<name> FireAnims;
var name LastFireAnim;

/*function PlayFiring()
{
	local name fa;

	if( FRand()<0.7 ) // Randomly swap animations.
	{
		fa = FireAnim2;
		FireAnim2 = FireAnim;
		FireAnim = fa;
	}
	Super.PlayFiring();
}
*/
function PlayFiring()
{
	Super.PlayFiring();
}

simulated event ModeDoFire()
{
	local int AnimToPlay;

	if(FireAnims.length > 0)
	{

		AnimToPlay = rand(FireAnims.length);

		LastFireAnim = FireAnim;
		FireAnim = FireAnims[AnimToPlay];

		DamagedelayMin = default.DamagedelayMin;

		//  3  and 2 should never play consecutively. it looks screwey.
		//  3 should never repeat directly after itself. buffer with 1

		if ( LastFireAnim == FireAnims[1] && FireAnim == FireAnims[2] ||
			LastFireAnim == FireAnims[2] && FireAnim == FireAnims[1] ||
			LastFireAnim == FireAnims[2] && FireAnim == FireAnims[2] )
		{
			FireAnim = FireAnims[0];
		}
	}

	Super(KFMeleeFire).ModeDoFire();
}

defaultproperties
{
     FireAnims(0)="Stab1"
     FireAnims(1)="Stab2"
     FireAnims(2)="Stab2"
     FireAnims(3)="Stab1"
     MeleeDamage=1200
     ProxySize=0.120000
     DamagedelayMin=0.420000
     DamagedelayMax=0.420000
     hitDamageClass=Class'IDRPGMod.DamTypeButterFlySA'
     MeleeHitSounds(0)=SoundGroup'KF_AxeSnd.Axe_HitFlesh'
     HitEffectClass=Class'KFMod.KnifeHitEffect'
     WideDamageMinHitAngle=0.650000
     FireRate=1.100000
     BotRefireRate=0.001000
}
