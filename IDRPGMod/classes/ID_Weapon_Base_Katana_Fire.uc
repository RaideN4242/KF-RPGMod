class ID_Weapon_Base_Katana_Fire extends ID_RPG_Base_Weapon_Melee_Fire;
var() array<name> FireAnims;

simulated event ModeDoFire()
{
    local int AnimToPlay;

    if(FireAnims.length > 0)
    {
        AnimToPlay = rand(FireAnims.length);
        FireAnim = FireAnims[AnimToPlay];
    }

    Super.ModeDoFire();

}

defaultproperties
{
     FireAnims(0)="Fire"
     FireAnims(1)="Fire2"
     FireAnims(2)="fire3"
     FireAnims(3)="Fire4"
     FireAnims(4)="Fire5"
     FireAnims(5)="Fire6"
     MeleeDamage=1000
     //maxAdditionalDamage=35
     ProxySize=0.150000
     weaponRange=95.000000
     DamagedelayMin=0.320000
     DamagedelayMax=0.320000
     hitDamageClass=Class'IDRPGMod.ID_Weapon_Base_Katana_DamageType'
     MeleeHitSounds(0)=SoundGroup'KF_KatanaSnd.Katana_HitFlesh'
     HitEffectClass=Class'KFMod.AxeHitEffect'
     FireRate=18
     BotRefireRate=3
}
