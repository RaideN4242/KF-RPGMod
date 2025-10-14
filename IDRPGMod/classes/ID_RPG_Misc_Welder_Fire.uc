class ID_RPG_Misc_Welder_Fire extends ID_RPG_Base_Weapon_Melee_Fire;

var Actor LastHitActor;
var localized string NoWeldTargetMessage;
var localized string CantWeldTargetMessage;
var float FailTime;

function PlayFiring()
{
	if ( Weapon.Mesh != None )
	{
		if ( FireCount > 0 )
		{
			if ( Weapon.HasAnim(FireLoopAnim) )
				Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
			else Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
		}
	}
	else Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
	Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,Default.FireAnimRate/FireAnimRate,false);
	ClientPlayForceFeedback(FireForce);  
	FireCount++;
}


simulated Function Timer()
{
	local Actor HitActor;
	local vector StartTrace, EndTrace, HitLocation, HitNormal,AdjustedLocation;
	local rotator PointRot;
	local int MyDamage;

	If( !KFWeapon(Weapon).bNoHit )
	{
		MyDamage = MeleeDamage;

		if ( ID_RPG_Base_HumanPawn(Instigator) != none)
		{
			
			MyDamage = float(MyDamage);
			MyDamage *= 1 +  class'ID_Skill_Welder'.static.GetWeldDamageMulti(ID_RPG_Base_HumanPawn(Instigator));
		}

		PointRot = Instigator.GetViewRotation();
		StartTrace = Instigator.Location + Instigator.EyePosition();

		if( AIController(Instigator.Controller)!=None && Instigator.Controller.Target!=None )
		{
			EndTrace = StartTrace + vector(PointRot)*weaponRange;
			Weapon.bBlockHitPointTraces = false;
			HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);
			Weapon.bBlockHitPointTraces = Weapon.default.bBlockHitPointTraces;

			if( HitActor==None )
			{
				EndTrace = Instigator.Controller.Target.Location;
				Weapon.bBlockHitPointTraces = false;
				HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);
				Weapon.bBlockHitPointTraces = Weapon.default.bBlockHitPointTraces;
			}
			if( HitActor==None )
				HitLocation = Instigator.Controller.Target.Location;
			HitActor = Instigator.Controller.Target;
		}
		else
		{
			EndTrace = StartTrace + vector(PointRot)*weaponRange;
			Weapon.bBlockHitPointTraces = false;
			HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);
			Weapon.bBlockHitPointTraces = Weapon.default.bBlockHitPointTraces;
		}

		LastHitActor = KFDoorMover(HitActor);
		if (LastHitActor == none)
			LastHitActor = SVehicle(HitActor);
		if( LastHitActor!=none && Level.NetMode!=NM_Client )
		{
			AdjustedLocation = Hitlocation;
			AdjustedLocation.Z = (Hitlocation.Z - 0.15 * Instigator.collisionheight);
			HitActor.TakeDamage(MyDamage, Instigator, HitLocation , vector(PointRot),hitDamageClass);
			Spawn(class'KFWelderHitEffect',,, AdjustedLocation, rotator(HitLocation - StartTrace));
		}
	}
}


function KFDoorMover GetDoor()
{
	local Actor A;
	local vector Dummy,End,Start;

	if( AIController(Instigator.Controller)!=None )
		Return KFDoorMover(Instigator.Controller.Target);
	Start = Instigator.Location+Instigator.EyePosition();
	End = Start+vector(Instigator.GetViewRotation())*weaponRange;
	Instigator.bBlockHitPointTraces = false;
	A = Instigator.Trace(Dummy,Dummy,End,Start,True);
	Instigator.bBlockHitPointTraces = Instigator.default.bBlockHitPointTraces;
	return KFDoorMover(A);
}

function SVehicle GetTurret()
{
	local Actor A;
	local vector Dummy,End,Start;

	Start = Instigator.Location+Instigator.EyePosition();
	End = Start+vector(Instigator.GetViewRotation())*weaponRange;
	Instigator.bBlockHitPointTraces = false;
	A = Instigator.Trace(Dummy,Dummy,End,Start,True);
	Instigator.bBlockHitPointTraces = Instigator.default.bBlockHitPointTraces;
	return SVehicle(A);
}

function DemoSentry GetDemoSentry()
{
	local Actor A;
	local vector Dummy,End,Start;

	Start = Instigator.Location+Instigator.EyePosition();
	End = Start+vector(Instigator.GetViewRotation())*weaponRange;
	Instigator.bBlockHitPointTraces = false;
	A = Instigator.Trace(Dummy,Dummy,End,Start,True);
	Instigator.bBlockHitPointTraces = Instigator.default.bBlockHitPointTraces;
	return DemoSentry(A);
}

function bool AllowFire()
{
	local KFDoorMover WeldTarget;
	local SVehicle WeldTurret;
	local DemoSentry DemoSentryTurret;

	WeldTarget = GetDoor();
	WeldTurret = GetTurret();
	DemoSentryTurret = GetDemoSentry();
	// Can't use welder, if no door.
	if ( WeldTarget == none && WeldTurret == none && DemoSentryTurret == none )
	{
		if ( KFPlayerController(Instigator.Controller) != none )
		{
			KFPlayerController(Instigator.Controller).CheckForHint(54);

			if ( FailTime + 0.5 < Level.TimeSeconds )
			{
				PlayerController(Instigator.Controller).ClientMessage(NoWeldTargetMessage, 'CriticalEvent');
				FailTime = Level.TimeSeconds;
			}

		}

		return false;
	}

	if( WeldTarget != none && WeldTarget.bDisallowWeld)
	{
		if( PlayerController(Instigator.controller)!=None )
			PlayerController(Instigator.controller).ClientMessage(CantWeldTargetMessage, 'CriticalEvent');
		return false;
	}


	return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire ;

}

defaultproperties
{
     NoWeldTargetMessage="You must be near a weldable door to use the welder."
     CantWeldTargetMessage="You cannot weld this door."
     MeleeDamage=10
     DamagedelayMin=0.100000
     DamagedelayMax=0.100000
     hitDamageClass=Class'KFMod.DamTypeWelder'
     MeleeHitSounds(0)=Sound'PatchSounds.WelderFire'
     TransientSoundVolume=1.800000
     FireRate=0.200000
     AmmoClass=Class'KFMod.WelderAmmo'
     AmmoPerFire=20
}
