class ID_RPG_Base_Weapon_Fire extends KFFire
	abstract;
	
var float MaxRangeVar;

function float GetFireSpeed()
{
	if (ID_RPG_Base_HumanPawn(Instigator) != none)
	{
		return  1 + class'ID_Skill_FireSpeed'.static.GetFireSpeedMulti(ID_RPG_Base_HumanPawn(Instigator), ID_RPG_Base_Weapon(Weapon));
	}

	return 1;
}

event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	if( Instigator==None || Instigator.Controller==none )
		return;

	Spread = GetSpread();

	Rec = GetFireSpeed();
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
	ReloadAnimRate = default.ReloadAnimRate*Rec;
	Rec = 1;

	if ( ID_RPG_Base_HumanPawn(Instigator) != none )
	{
		Rec -= class'ID_Skill_DecreasedRecoil'.static.GetRecoilDecreaseMulti(ID_RPG_Base_HumanPawn(Instigator), ID_RPG_Base_Weapon(Weapon));
		//log("Recoil:" @ Rec);
		Spread = Spread * Rec;
	}

	LastFireTime = Level.TimeSeconds;

	if (Weapon.Owner != none && AllowFire() && !bFiringDoesntAffectMovement)
	{
		if (FireRate > 0.25)
		{
			Weapon.Owner.Velocity.x *= 0.1;
			Weapon.Owner.Velocity.y *= 0.1;
		}
		else
		{
			Weapon.Owner.Velocity.x *= 0.5;
			Weapon.Owner.Velocity.y *= 0.5;
		}
	}

	Super(InstantFire).ModeDoFire();

	// client
	if (Instigator.IsLocallyControlled())
	{
		if( bDoClientRagdollShotFX && Weapon.Level.NetMode == NM_Client )
		{
			DoClientOnlyFireEffect();
		}
		HandleRecoil(Rec);
	}
}

function float MaxRange()
{
	TraceRange = MaxRangeVar;
	return TraceRange;
}

defaultproperties
{
     MaxRangeVar=12000.000000
}
