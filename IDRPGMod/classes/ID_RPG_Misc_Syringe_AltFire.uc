class ID_RPG_Misc_Syringe_AltFire extends ID_RPG_Base_Weapon_Fire;

var float InjectDelay;
var float HealeeRange;

function DoFireEffect()
{
	SetTimer(InjectDelay, False);
}

Function Timer()
{
	local float HealSum;

	HealSum = ID_RPG_Misc_Syringe(Weapon).HealBoostAmount;

	if ( ID_RPG_Base_HumanPawn(Instigator) != none )
	{
		HealSum *= 1 + class'ID_Skill_Doctor'.static.GetHealPotencyMulti(ID_RPG_Base_HumanPawn(Instigator));
	}

	Weapon.ConsumeAmmo(ThisModeNum, AmmoPerFire);
	Instigator.GiveHealth(HealSum, Instigator.HealthMax);
}

function bool AllowFire()
{
//	if (Instigator.Health >= Instigator.HealthMax)
/*	if ( Instigator.Health == Instigator.HealthMax ||
		(ID_RPG_Base_HumanPawn(Instigator)!=none &&
		(ID_RPG_Base_HumanPawn(Instigator).healthToGive + Instigator.Health) >= ID_RPG_Base_HumanPawn(Instigator).ClientHealthMax) )*/
	if(ID_RPG_Base_HumanPawn(Instigator)!=none)
	{
		if(Instigator.Health>=Instigator.default.HealthMax+
			class'ID_Skill_MaxHP'.static.GetAdditionalHP(ID_RPG_Base_HumanPawn(Instigator).getRepLink())+
			ID_RPG_Base_HumanPawn(Instigator).GetAdditionalHPOfPlayer())
		{
			return false;
		}
	}
	else if(Instigator.Health>=Instigator.HealthMax)
	{
		return false;
	}

	return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire;
}

event ModeDoFire()
{
	Load = 0;
	Super.ModeDoFire(); // We don't consume the ammo just yet.	
}

function PlayFiring()
{
	if ( Weapon.Mesh != None )
	{
		if ( FireCount > 0 )
		{
			if ( Weapon.HasAnim(FireLoopAnim) )
			{
				Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
			}
			else
			{
				Weapon.PlayAnim(FireAnim, FireAnimRate, 0.0);
			}
		}
		else
		{
			Weapon.PlayAnim(FireAnim, FireAnimRate, 0.0);
		}
	}
	Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,Default.FireAnimRate/FireAnimRate,false);
	ClientPlayForceFeedback(FireForce);  // jdf

	FireCount++;
}

defaultproperties
{
     InjectDelay=0.100000
     HealeeRange=70.000000
     TransientSoundVolume=1.800000
     FireAnim="AltFire"
     FireRate=3.600000
     AmmoPerFire=500
}
