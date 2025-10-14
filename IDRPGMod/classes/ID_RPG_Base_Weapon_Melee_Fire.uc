class ID_RPG_Base_Weapon_Melee_Fire extends KFMeleeFire; 

var int MeleeDamage;
/*
function float GetFireSpeed()
{
	if ( ID_RPG_Base_HumanPawn(Instigator) != none )
	{
		return  1 + class'ID_Skill_FireSpeed'.static.GetFireSpeedMulti(ID_RPG_Base_HumanPawn(Instigator), ID_RPG_Base_Weapon(Weapon));
	}

	return 1.0;
}
*/

simulated event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	Rec = GetFireSpeed();
	SetTimer(DamagedelayMin/Rec, False);
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
	ReloadAnimRate = default.ReloadAnimRate*Rec;

	if (MaxHoldTime > 0.0)
		HoldTime = FMin(HoldTime, MaxHoldTime);

	// server
	if (Weapon.Role == ROLE_Authority)
	{
		Weapon.ConsumeAmmo(ThisModeNum, Load);
		DoFireEffect();

		HoldTime = 0;   // if bot decides to stop firing, HoldTime must be reset first
		if ( (Instigator == None) || (Instigator.Controller == None) )
			return;

		if ( AIController(Instigator.Controller) != None )
			AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

		Instigator.DeactivateSpawnProtection();
	}

	// client
	if (Instigator.IsLocallyControlled())
	{
		ShakeView();
		PlayFiring();
		FlashMuzzleFlash();
		StartMuzzleSmoke();
		ClientPlayForceFeedback(FireForce);
	}
	else // server
		ServerPlayFiring();

	Weapon.IncrementFlashCount(ThisModeNum);

	// set the next firing time. must be careful here so client and server do not get out of sync
	if (bFireOnRelease)
	{
		if (bIsFiring)
			NextFireTime += MaxHoldTime + FireRate;
		else
			NextFireTime = Level.TimeSeconds + FireRate;
	}
	else
	{
		NextFireTime += FireRate;
		NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
	}

	Load = AmmoPerFire;
	HoldTime = 0;

	if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
	{
		bIsFiring = false;
		Weapon.PutDown();
	}


	Weapon.Owner.Velocity.x *= ID_RPG_Base_Weapon_Melee(Weapon).ChopSlowRate;
	Weapon.Owner.Velocity.y *= ID_RPG_Base_Weapon_Melee(Weapon).ChopSlowRate;
}

simulated function Timer()
{
	local Actor HitActor;
	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local rotator PointRot;
	local int MyDamage;
	local bool bBackStabbed;

	// Changed to remove the random in Balance Round 5
	MyDamage = MeleeDamage;

	If( !ID_RPG_Base_Weapon(Weapon).bNoHit )
	{
		// Changed to remove the random in Balance Round 6
		MyDamage = MeleeDamage;
		StartTrace = Instigator.Location + Instigator.EyePosition();

		if( Instigator.Controller!=None && PlayerController(Instigator.Controller)==None && Instigator.Controller.Enemy!=None )
		{
			PointRot = rotator(Instigator.Controller.Enemy.Location-StartTrace); // Give aimbot for bots.
		}
		else
		{
			PointRot = Instigator.GetViewRotation();
		}

		EndTrace = StartTrace + vector(PointRot)*weaponRange;
		HitActor = Instigator.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (HitActor!=None)
		{
			ImpactShakeView();

			if( HitActor.IsA('ExtendedZCollision') && HitActor.Base != none &&
				HitActor.Base.IsA('KFMonster') )
			{
				HitActor = HitActor.Base;
			}

			if ( (HitActor.IsA('KFMonster') || HitActor.IsA('KFHumanPawn')) && ID_RPG_Base_Weapon_Melee(Weapon).BloodyMaterial!=none )
			{
				Weapon.Skins[ID_RPG_Base_Weapon_Melee(Weapon).BloodSkinSwitchArray] = ID_RPG_Base_Weapon_Melee(Weapon).BloodyMaterial;
				Weapon.texture = Weapon.default.Texture;
			}
			if( Level.NetMode==NM_Client )
			{
				Return;
			}

			if( HitActor.IsA('Pawn') && !HitActor.IsA('Vehicle')
			&& (Normal(HitActor.Location-Instigator.Location) dot vector(HitActor.Rotation))>0 ) // Fixed in Balance Round 2
			{
				bBackStabbed = true;

				MyDamage*=2; // Backstab >:P
			}
			
			//log("Damage in W"@MyDamage);

			if( (KFMonster(HitActor)!=none) )
			{
			//	log(VSize(Instigator.Velocity));

				KFMonster(HitActor).bBackstabbed = bBackStabbed;

				HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), hitDamageClass) ;

				if(MeleeHitSounds.Length > 0)
				{
					Weapon.PlaySound(MeleeHitSounds[Rand(MeleeHitSounds.length)],SLOT_None,MeleeHitVolume,,,,false);
				}

				if(VSize(Instigator.Velocity) > 300 && KFMonster(HitActor).Mass <= Instigator.Mass)
				{
					KFMonster(HitActor).FlipOver();
				}

			}
			else
			{
				HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), hitDamageClass) ;
				Spawn(HitEffectClass,,, HitLocation, rotator(HitLocation - StartTrace));
				//if( KFWeaponAttachment(Weapon.ThirdPersonActor)!=None )
				//  KFWeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(HitActor,HitLocation,HitNormal);

				//Weapon.IncrementFlashCount(ThisModeNum);
			}
		}
	}
}

function DoFireEffect()
{

}

defaultproperties
{
	bWaitForRelease=True
}
