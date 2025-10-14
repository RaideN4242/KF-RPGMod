class ID_Weapon_Base_Turret_Base extends ID_RPG_Base_Weapon;

var() int TurretHealth;
var ID_Weapon_Base_Turret_Sentry_Base CurrentSentry;
var class<ID_Weapon_Base_Turret_Sentry_Base> SentryClass;
var class<ID_Weapon_Base_Turret_Sentry_Base> SentryStationaryClass;
var bool bSentryDeployed;
var() globalconfig bool bStationaryTurret;

replication
{
	reliable if(Role==ROLE_Authority)
		TurretHealth;

	reliable if(Role==ROLE_Authority && bNetOwner)
		bSentryDeployed;
}

simulated function Weapon WeaponChange(byte F, bool bSilent)
{
	if(InventoryGroup==F && !bSentryDeployed)
		return self;
	else if ( Inventory == None )
		return None;
	else return Inventory.WeaponChange(F,bSilent);
}

event ServerStartFire(byte Mode)
{
	local Rotator R;
	local Vector Spot;

	if(Instigator != none && Instigator.Weapon!=self)
	{
		if(Instigator.Weapon == none)
		{
			Instigator.ServerChangedWeapon(none, self);
		}
		else
		{
			Instigator.Weapon.SynchronizeWeapon(self);
		}
	
		return;
	}

	if(CurrentSentry == none)
	{
		R.Yaw = Instigator.Rotation.Yaw;
		Spot = (vector(R) * (Instigator.CollisionRadius + 70.0)) + Instigator.Location;

		if(FastTrace(Spot, Instigator.Location))
		{
			if(bStationaryTurret)
			{
				CurrentSentry = Spawn(SentryStationaryClass,,, Spot, R);
			}
			else
			{
				CurrentSentry = Spawn(SentryClass,,, Spot, R);
			}

			if(CurrentSentry != none)
			{
				if(PlayerController(Instigator.Controller) != none)
				{
					PlayerController(Instigator.Controller).ReceiveLocalizedMessage(MessageClass, 1);
				}

				CurrentSentry.SetOwningPlayer(Instigator, self);
				bSentryDeployed = true;

				if(ThirdPersonActor != none)
				{
					InventoryAttachment(ThirdPersonActor).bFastAttachmentReplication = false;
					ThirdPersonActor.bHidden = true;
				}

				CurrentSentry.SetSettings(Instigator, self);

				return;
			}
		}
	
		if(PlayerController(Instigator.Controller) != none)
		{
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage(MessageClass, 0);
		}
	}
}

simulated function Destroyed()
{
	Super(KFWeapon).Destroyed();
}

defaultproperties
{
     MessageClass=Class'IDRPGMod.ID_Message_Turret'
}
