class MySawZombieController extends ID_RPG_Base_Monster_Controller;

var	bool	bDoneSpottedCheck;

var	name		AnimWaitingFor;
var	float	  WaitAnimTimeout;
var	int		AnimWaitChannel;

state WaitForAnim
{
	function WaitTimeout()
	{
		if( bUseFreezeHack )
		{
			if( Pawn!=None )
			{
				Pawn.AccelRate = Pawn.Default.AccelRate;
				Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
			}
			bUseFreezeHack = False;
		}

		AnimEnd(AnimWaitChannel);
	}
	
	function Tick( float Delta )
	{
		Global.Tick(Delta);
		
		if( WaitAnimTimeout > 0 )
		{
			WaitAnimTimeout -= Delta;

			if( WaitAnimTimeout <= 0 )
			{
				WaitAnimTimeout = 0;
				WaitTimeout();
			}
		}

		if( bUseFreezeHack )
		{
			MoveTarget = None;
			MoveTimer = -1;
			Pawn.Acceleration = vect(0,0,0);
			Pawn.GroundSpeed = 1;
			Pawn.AccelRate = 0;
		}		
	}
}

function SetWaitForAnimTimout(float NewWaitAnimTimeout, name AnimToWaitFor)
{
	WaitAnimTimeout = NewWaitAnimTimeout;
	AnimWaitingFor = AnimToWaitFor;
}

state ZombieHunt
{
	event SeePlayer(Pawn SeenPlayer)
	{
		if ( !bDoneSpottedCheck && PlayerController(SeenPlayer.Controller) != none )
		{
			// 25% chance of first player to see this Scrake saying something
			if ( !KFGameType(Level.Game).bDidSpottedScrakeMessage && FRand() < 0.25 )
			{
				PlayerController(SeenPlayer.Controller).Speech('AUTO', 14, "");
				KFGameType(Level.Game).bDidSpottedScrakeMessage = true;
			}

			bDoneSpottedCheck = true;
		}

		super.SeePlayer(SeenPlayer);
	}
}

function TimedFireWeaponAtEnemy()
{
	if ( (Enemy == None) || FireWeaponAt(Enemy) )
		SetCombatTimer();
	else SetTimer(0.01, True);
}

state ZombieCharge
{
	// Don't do this in this state
	function GetOutOfTheWayOfShot(vector ShotDirection, vector ShotOrigin){}

	function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
	{
		return false;
	}
	function bool TryStrafe(vector sideDir)
	{
		return false;
	}
	function Timer()
	{
		Disable('NotifyBump');
		Target = Enemy;
		TimedFireWeaponAtEnemy();
	}

WaitForAnim:

	While( Monster(Pawn).bShotAnim )
		Sleep(0.25);
	if ( !FindBestPathToward(Enemy, false,true) )
		GotoState('ZombieRestFormation');
Moving:
	MoveToward(Enemy);
	WhatToDoNext(17);
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
}

defaultproperties
{
}
