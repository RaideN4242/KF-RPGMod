class ID_Weapon_Base_AA12AS extends ID_RPG_Base_Weapon
	abstract;

//var		int			MagAmmoRemaining;// How many bullets are left in the weapon's magazine //**
//var		bool			bForceLeaveIronsights;  // Force the weapon out of ironsights on the next tick //**
//var()	  int			MagCapacity;	 // How Much ammo this weapon can hold in its magazine //**
//var			int				SellValue; //**

/*
replication
{
	reliable if(Role == ROLE_Authority) 
		MagAmmoRemaining, bForceLeaveIronsights;

	reliable if( bNetDirty && bNetOwner && (Role==ROLE_Authority) )
		MagCapacity, SellValue;
	
	reliable if(Role < ROLE_Authority)
		ReloadMeNow, ServerSetAiming, ServerSpawnLight, ServerRequestAutoReload,
		ServerInterruptReload;

	reliable if(Role == ROLE_Authority)
		ClientReload, ClientFinishReloading, ClientReloadEffects, FlashLight,
		ClientInterruptReload, ClientForceKFAmmoUpdate; 
	reliable if(Role < ROLE_Authority)
		ServerChangeFireMode;
}*/

// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
	if(ReadyToFire(0))
	{
		DoToggle();
	}
}

// Toggle semi/auto fire
simulated function DoToggle ()
{
	local PlayerController Player;

	Player = Level.GetLocalPlayerController();
	if ( Player!=None )
	{
		//PlayOwnedSound(sound'Inf_Weapons_Foley.stg44_firemodeswitch01',SLOT_None,2.0,,,,false);
		FireMode[0].bWaitForRelease = !FireMode[0].bWaitForRelease;
		if ( FireMode[0].bWaitForRelease )
			Player.ReceiveLocalizedMessage(class'KFmod.BullpupSwitchMessage',0);
		else Player.ReceiveLocalizedMessage(class'KFmod.BullpupSwitchMessage',1);
	}
	Super.DoToggle();

	ServerChangeFireMode(FireMode[0].bWaitForRelease);
}

// Set the new fire mode on the server
function ServerChangeFireMode(bool bNewWaitForRelease)
{
	FireMode[0].bWaitForRelease = bNewWaitForRelease;
}

exec function SwitchModes()
{
	DoToggle();
}

simulated function bool CanZoomNow()
{
	Return (!FireMode[0].bIsFiring && Instigator!=None && Instigator.Physics!=PHYS_Falling);
}
/*
simulated function WeaponTick(float dt)
{
	local float LastSeenSeconds,ReloadMulti;

	if ( (Level.NetMode == NM_Client) || Instigator == None || KFFriendlyAI(Instigator.Controller) == none && Instigator.PlayerReplicationInfo == None)
		return;

	// Turn it off on death  / battery expenditure
	if (FlashLight != none)
	{
		// Keep the 1Pweapon client beam up to date.
		AdjustLightGraphic();
		if (FlashLight.bHasLight)
		{
			if (Instigator.Health <= 0 || KFHumanPawn(Instigator).TorchBatteryLife <= 0 || Instigator.PendingWeapon != none )
			{
				//Log("Killing Light...you're out of batteries, or switched / dropped weapons");
				KFHumanPawn(Instigator).bTorchOn = false;
				ServerSpawnLight();
			}
		}
	}

	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if(!bIsReloading)
	{
		if(!Instigator.IsHumanControlled())
		{
			LastSeenSeconds = Level.TimeSeconds - Instigator.Controller.LastSeenTime;
			if(MagAmmoRemaining == 0 || ((LastSeenSeconds >= 5 || LastSeenSeconds > MagAmmoRemaining) && MagAmmoRemaining < MagCapacity))
				ReloadMeNow();
		}
	}
	else
	{
		if((Level.TimeSeconds - ReloadTimer) >= ReloadRate)
		{
			if(AmmoAmount(0) <= MagCapacity && !bHoldToReload)
			{
				MagAmmoRemaining = AmmoAmount(0);
				ActuallyFinishReloading();
			}
			else
			{
				ReloadMulti = 1.0;
				if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none)
				{
					ReloadMulti +=  class'ID_Skill_ReloadSpeed'.static.GetReloadSpeedMulti(ID_RPG_Base_HumanPawn(Instigator), self); 
					ReloadAnimRate = ReloadMulti / default.ReloadRate;
				}

				AddReloadedAmmo();

				if( bHoldToReload )
				{
					NumLoadedThisReload++;
				}

				if(MagAmmoRemaining < MagCapacity && MagAmmoRemaining < AmmoAmount(0) && bHoldToReload)
					ReloadTimer = Level.TimeSeconds;
				if(MagAmmoRemaining >= MagCapacity || MagAmmoRemaining >= AmmoAmount(0) || !bHoldToReload || bDoSingleReload)
					ActuallyFinishReloading();
				else if( Level.NetMode!=NM_Client )
					Instigator.SetAnimAction(WeaponReloadAnim);
			}
		}
		else if(bIsReloading && !bReloadEffectDone && Level.TimeSeconds - ReloadTimer >= ReloadRate / 2)
		{
			bReloadEffectDone = true;
			ClientReloadEffects();
		}
	}
}*/
/////////////////////////////
/*exec function ReloadMeNow()
{
	local float ReloadMulti;

	if(!AllowReload())
		return;

	if ( bHasAimingMode && bAimingRifle )
	{
		FireMode[1].bIsFiring = False;

		ZoomOut(false);
		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}
	
	ReloadMulti = 1.0;
	if ( ID_RPG_Base_HumanPawn(Instigator) != none)
	{
		ReloadMulti +=  class'ID_Skill_ReloadSpeed'.static.GetReloadSpeedMulti(ID_RPG_Base_HumanPawn(Instigator), self); 
	}

	bIsReloading = true;
	ReloadTimer = Level.TimeSeconds;
	ReloadRate = Default.ReloadRate / ReloadMulti;
	
	if( bHoldToReload )
	{
		NumLoadedThisReload = 0;
	}

	ClientReload();
	Instigator.SetAnimAction(WeaponReloadAnim);

	// Reload message commented out for now - Ramm
	if ( Level.Game.NumPlayers > 1 && KFGameType(Level.Game).bWaveInProgress && KFPlayerController(Instigator.Controller) != none &&
		Level.TimeSeconds - KFPlayerController(Instigator.Controller).LastReloadMessageTime > KFPlayerController(Instigator.Controller).ReloadMessageDelay )
	{
		KFPlayerController(Instigator.Controller).Speech('AUTO', 2, "");
		KFPlayerController(Instigator.Controller).LastReloadMessageTime = Level.TimeSeconds;
	}
}*/

defaultproperties
{
     MagCapacity=20
     ReloadRate=3.133000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_AA12"
     HudImage=Texture'KillingFloor2HUD.WeaponSelect.AA12_unselected'
     SelectedHudImage=Texture'KillingFloor2HUD.WeaponSelect.AA12'
     Weight=8.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_AA12'
     PlayerIronSightFOV=80.000000
     ZoomedDisplayFOV=45.000000
     FireModeClass(0)=Class'IDRPGMod.ID_Weapon_Base_AA12AS_Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'KF_AA12Snd.AA12_Select'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="An advanced automatic shotgun. Fires steel ball shot in semi or full auto."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=65.000000
     Priority=100
     InventoryGroup=4
     GroupOffset=6
     PickupClass=Class'IDRPGMod.ID_Weapon_Base_AA12AS_Pickup'
     PlayerViewOffset=(X=25.000000,Y=20.000000,Z=-2.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.AA12Attachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="AA12AS"
     Mesh=SkeletalMesh'KF_Weapons2_Trip.AA12_Trip'
     Skins(0)=Combiner'KF_Weapons2_Trip_T.Special.AA12_cmb'
     TransientSoundVolume=1.250000
}
