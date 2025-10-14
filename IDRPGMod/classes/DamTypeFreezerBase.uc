class DamTypeFreezerBase extends KFWeaponDamageType
	abstract;

var float   FreezeRatio; // percent of damage used for freezing effect

// Freeze over Time
var int	FoT_Duration;   // for how long zed will freeze after receiving this damage
var float   FoT_Ratio;	 // freeze per second in percent of damage received

defaultproperties
{
     FreezeRatio=1.000000
     WeaponClass=Class'IDRPGMod.MP7Dual'
     DeathString="%o frozen by %k."
     FemaleSuicide="%o froze till death."
     MaleSuicide="%o froze till death."
     bArmorStops=False
     DeathOverlayMaterial=Texture'DZResPack.Overlay.IceOverlay'
     DeathOverlayTime=5.000000
}
