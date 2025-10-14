class ID_GUI_Panel_ItemInfo extends GUIBuyDescInfoPanel;

var automated GUILabel ItemName;
var automated GUIImage ItemImage, ItemNameBG;
var automated GUIScrollTextBox InfoPanel;
var automated localized String Weight;
var class<Pickup> OldPickupClass;

function InitComponent( GUIController MyController, GUIComponent MyOwner )
{
	Super.InitComponent(MyController,MyOwner);
	InfoPanel.SetVisibility(false);
}

static function string GetDamage(class<WeaponFire> PrimaryFire)
{
	if (class<ID_RPG_Base_Weapon_Melee_Fire>(PrimaryFire) != none)
		return "" $ class<ID_RPG_Base_Weapon_Melee_Fire>(PrimaryFire).default.MeleeDamage;
		
	else if (class<ID_RPG_Base_Weapon_Shotgun_Fire>(PrimaryFire) != none)
		return class<ID_RPG_Base_Weapon_Shotgun_Fire>(PrimaryFire).default.ProjectileClass.default.Damage @ 
					"x" @ class<ID_RPG_Base_Weapon_Shotgun_Fire>(PrimaryFire).default.ProjPerFire;
	else
		return "" $ (class<ID_RPG_Base_Weapon_Fire>(PrimaryFire).default.DamageMin + 
						class<ID_RPG_Base_Weapon_Fire>(PrimaryFire).default.DamageMax) / 2;
}

static function float GetFireRate(class<WeaponFire> PrimaryFire)
{
	return 1.0f / PrimaryFire.default.FireRate;
}

function Display(GUIBuyable NewBuyable)
{
	local string Info;
	local int DamageRadius;
	local class<ID_RPG_Base_Weapon> Weapon;
	local class<ID_Weapon_Base_Turret> Turret;
	local class<ID_Weapon_Base_TurretM> Turret1;
//	local class<PMedKit> medkit1;
	local class<PTurretM> Turret2;
	local class<AKFTurret> AKFTurret;
	local class<SentryGunWYDTWeap> SentryGunWYDTWeap;
	local class<DemoSentryGun> DemoSentryGun;
	local class<WeaponFire> PrimaryFire;
	Info = "";
	if ( NewBuyable == none || NewBuyable.bIsFirstAidKit || NewBuyable.bIsVest )
	{
		InfoPanel.SetVisibility(false);
	}
	else if (class<DemoSentryGun>(NewBuyable.ItemWeaponClass) != none)
	{
		DemoSentryGun = class<DemoSentryGun>(NewBuyable.ItemWeaponClass);
		Info = "Damage:" @  DemoSentryGun.default.SentryClass.default.HitDamages;
		Info $= "|FireRate:" @  float(int(100 / DemoSentryGun.default.SentryClass.default.FireRateTime))*0.01;
		Info $= "|Weight:" @ int(NewBuyable.ItemWeight);
		Info $= "|HP:" @  DemoSentryGun.default.SentryClass.default.SentryHealth;
		Info $= "|*Doesn't have instant kill chance";
	}
	else if (class<AKFTurret>(NewBuyable.ItemWeaponClass) != none)
	{
		AKFTurret = class<AKFTurret>(NewBuyable.ItemWeaponClass);
		Info = "Damage:" @  AKFTurret.default.SentryClass.default.HitDamages;
		Info $= "|FireRate:" @  float(int(100 / AKFTurret.default.SentryClass.default.FireRateTime))*0.01;
		Info $= "|Weight:" @ int(NewBuyable.ItemWeight);
		Info $= "|HP:" @  AKFTurret.default.SentryClass.default.TurretHealth;
		Info $= "|*Doesn't have instant kill chance";
	}
	else if (class<SentryGunWYDTWeap>(NewBuyable.ItemWeaponClass) != none)
	{
		SentryGunWYDTWeap = class<SentryGunWYDTWeap>(NewBuyable.ItemWeaponClass);
		Info = "Damage:" @  SentryGunWYDTWeap.default.SentryClass.default.HitDamages;
		Info $= "|FireRate:" @  float(int(100 / SentryGunWYDTWeap.default.SentryClass.default.FireRateTime))*0.01;
		Info $= "|Weight:" @ int(NewBuyable.ItemWeight);
		Info $= "|HP:" @  SentryGunWYDTWeap.default.SentryClass.default.TurretHealth;
	}
	else if (class<VestRPGBase>(NewBuyable.ItemWeaponClass) != none)
	{
		Info = "HP/AP:"@ class<VestRPGBase>(NewBuyable.ItemWeaponClass).default.ArmorPlateStrength;;
		Info $= "|Weight:" @ int(NewBuyable.ItemWeight);
	}
	else if (class<ID_Weapon_Base_TurretM>(NewBuyable.ItemWeaponClass) != none)
	{
		Turret1 = class<ID_Weapon_Base_TurretM>(NewBuyable.ItemWeaponClass);
		Info = "Damage:" @  Turret1.default.SentryClass.default.HitDamages;
		Info $= "|FireRate:" @ 1 / Turret1.default.SentryClass.default.FireRateTime;
		Info $= "|Weight:" @ int(NewBuyable.ItemWeight);
		Info $= "|HP:" @  Turret1.default.SentryClass.default.TurretHealth;
		Info $= "|*Doesn't have instant kill chance";
	}
	else if (class<PTurretM>(NewBuyable.ItemWeaponClass) != none)
	{
		Turret2 = class<PTurretM>(NewBuyable.ItemWeaponClass);
		Info = "Damage:" @  Turret2.default.SentryClass.default.HitDamages;
		Info $= "|FireRate:" @ 1 / Turret2.default.SentryClass.default.FireRateTime;
		Info $= "|Weight:" @ int(NewBuyable.ItemWeight);
		Info $= "|HP:" @  Turret2.default.SentryClass.default.TurretHealth;
		Info $= "|*Doesn't have instant kill chance";
	}
	else if (class<ID_Weapon_Base_Turret>(NewBuyable.ItemWeaponClass) != none)
	{
		Turret = class<ID_Weapon_Base_Turret>(NewBuyable.ItemWeaponClass);
		Info = "Damage:" @  Turret.default.SentryClass.default.HitDamages;
		Info $= "|FireRate:" @  1 / Turret.default.SentryClass.default.FireRateTime;
		Info $= "|Weight:" @ int(NewBuyable.ItemWeight);
		Info $= "|HP:" @  Turret.default.SentryClass.default.TurretHealth;
		Info $= "|*Doesn't have instant kill chance";
	}
	else if (class<ID_RPG_Base_Weapon>(NewBuyable.ItemWeaponClass) != none)
	{
		Weapon = class<ID_RPG_Base_Weapon>(NewBuyable.ItemWeaponClass);
		PrimaryFire= Weapon.default.FireModeClass[0];
		Info = "Damage:" @  GetDamage(PrimaryFire);
		if (class<ID_RPG_Base_Weapon_Shotgun_Fire>(PrimaryFire) != none)
		{
			DamageRadius = class<ID_RPG_Base_Weapon_Shotgun_Fire>(PrimaryFire).default.ProjectileClass.default.DamageRadius;
			if (DamageRadius > 0)
				Info $= "|Damage radius:" @  DamageRadius;
		}
		Info $= "|Fire rate:" @  GetFireRate(PrimaryFire);
		if (class<ID_RPG_Base_Weapon_Melee>(NewBuyable.ItemWeaponClass) == none)
		{
			Info $= "|Mag capacity:" @ Weapon.default.MagCapacity;
			Info $= "|Reload speed:" @ Weapon.default.ReloadRate;
		}
		Info $= "|Weight:" @ int(NewBuyable.ItemWeight);
		Info $= "||*Note: Weapons of the same lvl have same Damage Per Second";
	}
	else if (ID_GUI_BuyableItem(NewBuyable).ItemUtilClass != none)
	{
		Info = ID_GUI_BuyableItem(NewBuyable).ItemUtilClass.static.GetItemInfo();
	}
	if (Info != "")
	{
		InfoPanel.SetContent(Info);
		InfoPanel.SetVisibility(true);
	}
	
	if ( NewBuyable != none )
	{
		ItemName.Caption = NewBuyable.ItemName;
		ItemNameBG.bVisible = true;
		ItemImage.Image = NewBuyable.ItemImage;

		OldPickupClass = NewBuyable.ItemPickupClass;
	}
	else
	{
		ItemName.Caption = "";
		ItemNameBG.bVisible = false;
		ItemImage.Image = none;
	}
	
	Super.Display(NewBuyable);
}

defaultproperties
{
     Begin Object Class=GUILabel Name=IName
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         TextFont="UT2LargeFont"
         WinTop=0.005236
         WinLeft=0.035800
         WinWidth=0.928366
         WinHeight=0.070000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     ItemName=GUILabel'IDRPGMod.ID_GUI_Panel_ItemInfo.IName'

     Begin Object Class=GUIImage Name=IImage
         ImageStyle=ISTY_Justified
         WinTop=0.100000
         WinLeft=0.250000
         WinWidth=0.450000
         WinHeight=0.450000
         RenderWeight=2.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ItemImage=GUIImage'IDRPGMod.ID_GUI_Panel_ItemInfo.IImage'

     Begin Object Class=GUIImage Name=INameBG
         Image=Texture'KF_InterfaceArt_tex.Menu.Innerborder_transparent'
         ImageStyle=ISTY_Stretched
         WinTop=-0.015493
         WinLeft=0.035800
         WinWidth=0.928366
         WinHeight=0.105446
     End Object
     ItemNameBG=GUIImage'IDRPGMod.ID_GUI_Panel_ItemInfo.INameBG'

     Begin Object Class=GUIScrollTextBox Name=InfoPanel_
         bNoTeletype=True
         OnCreateComponent=SkillEffectsScroll.InternalOnCreateComponent
         WinTop=0.400000
         WinLeft=0.100000
         WinWidth=0.800000
         WinHeight=0.550000
         RenderWeight=5.000000
     End Object
     InfoPanel=GUIScrollTextBox'IDRPGMod.ID_GUI_Panel_ItemInfo.InfoPanel_'

     Weight="Weight: %i blocks"
}
