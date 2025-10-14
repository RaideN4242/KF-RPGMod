class USSP_Mut_Basic_Admin extends Admin;

var localized string MSG_Help1;
var localized string MSG_Help2;
var localized string MSG_Help3;
var localized string MSG_Help4;
var localized string MSG_Help5;
var localized string MSG_Help6;
var localized string MSG_Help7;
var localized string MSG_Help8;
var localized string MSG_Help9;
var localized string MSG_Help10;
var localized string MSG_Help11;
var localized string MSG_Help12;
var localized string MSG_Help13;
var localized string MSG_Help14;
var localized string MSG_Help15;
var localized string MSG_Help16;
var localized string MSG_Help17;
var localized string MSG_ReSpawned;
var localized string MSG_ChangeSize;

function Pawn findPlayerByName(string PName)
{
	local Controller C; 
	local int namematch; 

	for(C=Level.ControllerList; C!=None; C=C.nextController)
	{
		if(C.IsA('PlayerController') || C.IsA('xBot'))
		{
			if(Len(C.PlayerReplicationInfo.PlayerName)>=3 && Len(PName)<3)
			{
				Log("Must be longer than 3 characters");
			}
			else
			{
				namematch=InStr(Caps(C.PlayerReplicationInfo.PlayerName), Caps(PName)); 

				if(namematch>=0)
				{
					return C.Pawn; 
				}
			}
		}
	}

	return none;
}

function Pawn verifyTarget(string target)
{
	local Pawn p;

	if(target=="")
	{
		return Pawn;
	}
	else
	{
		p=findPlayerByName(target);
	}

	if(p==None)
	{
		ClientMessage(target @ "is not currently in the game.");
	}

	return p;
}

function help_list(Controller C)
{
	local PlayerController PC;

	PC=PlayerController(C);

	if(PC==None)
	{
		return;
	}

	PC.ClientMessage(MSG_Help1);
	PC.ClientMessage(MSG_Help2);
	PC.ClientMessage(MSG_Help3);
	PC.ClientMessage(MSG_Help4);
	PC.ClientMessage(MSG_Help5);
	PC.ClientMessage(MSG_Help6);
	PC.ClientMessage(MSG_Help7);
	PC.ClientMessage(MSG_Help8);
	PC.ClientMessage(MSG_Help9);
	PC.ClientMessage(MSG_Help10);
	PC.ClientMessage(MSG_Help11);
	PC.ClientMessage(MSG_Help12);
	PC.ClientMessage(MSG_Help13);
	PC.ClientMessage(MSG_Help14);
	PC.ClientMessage(MSG_Help15);
	PC.ClientMessage(MSG_Help16);
	PC.ClientMessage(MSG_Help17);
}

exec function Help(string target)
{
	local Controller C;
	local int namematch;

	if(target=="")
	{
		target=PlayerReplicationInfo.PlayerName;

		for(C=Level.ControllerList; C!=None; C=C.nextController)
		{
			namematch=InStr(Caps(C.PlayerReplicationInfo.PlayerName), Caps(target));

			if(namematch>=0)
			{
				help_list(C);
				return;
			}
		}
	}
	else
	{
		for(C=Level.ControllerList; C!=None; C=C.nextController)
		{
			if(C.IsA('PlayerController') || C.IsA('xBot'))
			{
				namematch=InStr(Caps(C.PlayerReplicationInfo.PlayerName), Caps(target));

				if(namematch>=0)
				{
					help_list(C);
				}
			}
		}
	}
}

exec function Slap(string target, int iSlapDmg)
{
	local Pawn p;
	local Controller C;
	local int namematch;

	if(target=="all")
	{
		for(C=Level.ControllerList; C!=None; C=C.nextController)
		{
			if(C.IsA('PlayerController') || C.IsA('xBot'))
			{
				C.Pawn.ClientMessage("You've been Pimp slapped");
				ServerSay(Pawn.PlayerReplicationInfo.PlayerName@"PimpSlaps"@C.PlayerReplicationInfo.PlayerName@"like a bitch!");

				if(C.Pawn.Health>1)
				{
					C.Pawn.TakeDamage(iSlapDmg,Pawn,Vect(100000,100000,100000),Vect(100000,100000,100000),class'DamageType');
					C.Pawn.PlayTeleportEffect(true, true);
				}
			}
		}

		return;
	}
	else if(target=="")
	{
		P=verifyTarget(target);
		P.ClientMessage("You've been Pimp slapped!");
		ServerSay(Pawn.PlayerReplicationInfo.PlayerName@"PimpSlaps Himself like a bitch!");

		if(P.Health>1)
		{
			P.TakeDamage(iSlapDmg,Pawn,Vect(100000,100000,100000),Vect(100000,100000,100000),class'DamageType');
			P.PlayTeleportEffect(true, true);
		}

		return;
	}
	else
	{
		P=verifyTarget(target);

		if(P==none)
		{
			return;
		}

		for(C=Level.ControllerList; C!=None; C=C.nextController)
		{
			if(C.IsA('PlayerController') || C.IsA('xBot'))
			{
				namematch=InStr(Caps(C.PlayerReplicationInfo.PlayerName), Caps(target));

				if(namematch>=0)
				{
					C.Pawn.ClientMessage("You've been Pimp slapped!");
					ServerSay(Pawn.PlayerReplicationInfo.PlayerName@"PimpSlaps"@C.Pawn.PlayerReplicationInfo.PlayerName@"like a bitch!");

					if(C.Pawn.Health>1)
					{
						C.Pawn.TakeDamage(iSlapDmg,Pawn,Vect(100000,100000,100000),Vect(100000,100000,100000),class'DamageType');
						C.Pawn.PlayTeleportEffect(true, true);
					}
				}
			}
		}
	}
}

exec function HeadSize(string target, float newHeadSize)
{
	local Controller C;
	local int namematch;
	local Pawn p;

	if(target=="all")
	{
		for(C=Level.ControllerList; C!=None; C=C.nextController)
		{
			if(C.IsA('PlayerController') || C.IsA('xBot'))
			{
				if(C.Pawn!=none)
				{
					C.Pawn.ClientMessage(MSG_ChangeSize);
					C.Pawn.headscale=newHeadSize;
					C.Pawn.PlayTeleportEffect(true, true);
				}
			}
		}

		return;
	}
	else if(target=="")
	{
		P=verifyTarget(target);
		P.ClientMessage(MSG_ChangeSize);
		P.PlayTeleportEffect(true, true);
		P.headscale=newHeadSize;
		return;
	}
	else
	{
		P=verifyTarget(target);

		if(P==none)
		{
			return;
		}

		for(C=Level.ControllerList; C!=None; C=C.nextController)
		{
			if(C.IsA('PlayerController') || C.IsA('xBot'))
			{
				namematch=InStr(Caps(C.PlayerReplicationInfo.PlayerName), Caps(target));

				if(namematch>=0)
				{
					if(C.Pawn!=none)
					{
						C.Pawn.ClientMessage(MSG_ChangeSize);
						C.Pawn.headscale=newHeadSize;
						C.Pawn.PlayTeleportEffect(true, true);
					}
				}
			}
		}
	}
}

exec function PlayerSize(string target, float newPlayerSize)
{
	local Controller C;
	local int namematch;
	local Pawn p;
	local float oldsize;

	oldsize=C.Pawn.DrawScale;
/*
	if(newPlayerSize==0 || newPlayerSize>5)
	{
		ClientMessage("PlayerSize Cannot be 0 or greater than 5, causes game to crash");
		return;
	}
*/
	if(target=="all")
	{
		for(C=Level.ControllerList; C!=None; C=C.nextController)
		{
			if(C.IsA('PlayerController') || C.IsA('xBot'))
			{
				if(newPlayerSize<oldsize || oldsize==0)
				{
					C.Pawn.SetDrawScale((P.DrawScale*0)+1);
				}

				if(C.Pawn!=none)
				{
					C.Pawn.SetDrawScale(C.Pawn.DrawScale*newPlayerSize);
					C.Pawn.SetCollisionSize(C.Pawn.CollisionRadius*newPlayerSize, C.Pawn.CollisionHeight*newPlayerSize);
					C.Pawn.BaseEyeHeight*=newPlayerSize;
					C.Pawn.EyeHeight*=newPlayerSize;
					C.Pawn.PlayTeleportEffect(true, true);
				}
			}
		}

		return;
	}
	else if(target=="")
	{
		P=verifyTarget(target);
		P.ClientMessage(MSG_ChangeSize);

		if(newPlayerSize<oldsize || oldsize==0)
		{
			P.SetDrawScale((P.DrawScale*0)+1);
		}

		P.SetDrawScale(P.DrawScale*newPlayerSize);
		P.SetCollisionSize(P.CollisionRadius*newPlayerSize, P.CollisionHeight*newPlayerSize);
		P.BaseEyeHeight*=newPlayerSize;
		P.EyeHeight*=newPlayerSize;
		P.PlayTeleportEffect(true, true);
		return;
	}
	else
	{
		P=verifyTarget(target);

		if(P==none)
		{
			return;
		}

		for(C=Level.ControllerList; C!=None; C=C.nextController)
		{
			if(C.IsA('PlayerController') || C.IsA('xBot'))
			{
				namematch=InStr(Caps(C.PlayerReplicationInfo.PlayerName), Caps(target));

				if(namematch>=0)
				{
					C.Pawn.ClientMessage(MSG_ChangeSize);

					if(newPlayerSize<oldsize || oldsize==0)
					{
						C.Pawn.SetDrawScale((P.DrawScale*0)+1);
					}

					if(C.Pawn!=none)
					{
						C.Pawn.SetDrawScale(C.Pawn.DrawScale*newPlayerSize);
						C.Pawn.SetCollisionSize(C.Pawn.CollisionRadius*newPlayerSize, C.Pawn.CollisionHeight*newPlayerSize);
						C.Pawn.BaseEyeHeight*=newPlayerSize;
						C.Pawn.EyeHeight*=newPlayerSize;
						C.Pawn.PlayTeleportEffect(true, true);
					}
				}
			}
		}
	}
}

exec function Summon(string ClassName)
{
	local class<actor>NewClass;
	local vector SpawnLoc;

	NewClass=class<actor>(DynamicLoadObject(ClassName, class'Class'));

	if(NewClass!=None)
	{
		if(Pawn!=None)
		{
			SpawnLoc=Pawn.Location;
		}
		else
		{
			SpawnLoc=Location;
		}

		Spawn(NewClass,,,SpawnLoc+72*Vector(Rotation)+vect(0,0,1)*15);
	}
}

exec function AdvancedSummon(string ClassName, string target)
{
	local class<actor>NewClass;
	local vector SpawnLoc;
	local Pawn p;

	p=verifyTarget(target);

	if(p==None)
	{
		ClientMessage(target @ "is not on the game.");
		return;
	}

	NewClass=class<actor>(DynamicLoadObject(ClassName, class'Class'));

	if(NewClass!=None)
	{
		if(P!=None)
		{
			SpawnLoc=P.Location;
		}
		else
		{
			SpawnLoc=Location;
		}

		Spawn(NewClass,,,SpawnLoc+72*Vector(Rotation)+vect(0,0,1)*15);
	}
}

function ReSpawnRoutine(PlayerController C)
{
	local bool bTraderTime;

	if(C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && C.PlayerReplicationInfo.bOutOfLives)
	{
		Level.Game.Disable('Timer');
		C.PlayerReplicationInfo.bOutOfLives=false;
		C.PlayerReplicationInfo.NumLives=0;
		C.PlayerReplicationInfo.Score=Max(KFGameType(Level.Game).MinRespawnCash, int(C.PlayerReplicationInfo.Score));
		C.GotoState('PlayerWaiting');
		C.SetViewTarget(C);
		C.ClientSetBehindView(false);
		C.bBehindView=False;
		C.ClientSetViewTarget(C.Pawn);

		if(!Invasion(Level.Game).bWaveInProgress)
		{
			bTraderTime=true;
		}

		if(!bTraderTime)
		{
			Invasion(Level.Game).bWaveInProgress=false;
		}

		C.ServerReStartPlayer();

		if(!bTraderTime)
		{
			Invasion(Level.Game).bWaveInProgress=true;
		}

		Level.Game.Enable('Timer');
		C.ClientMessage(MSG_ReSpawned);
	}
}

exec function ReSpawn(string target)
{
	local Controller C;
	local int namematch;

	for(C=Level.ControllerList; C!=None; C=C.nextController)
	{
		if(C.IsA('PlayerController') || C.IsA('xBot'))
		{
			if(Target=="all")
			{
				ReSpawnRoutine(PlayerController(C));
			}
			else
			{
				namematch=InStr(Caps(C.PlayerReplicationInfo.PlayerName), Caps(target));

				if(namematch>=0)
				{
					ReSpawnRoutine(PlayerController(C));
				}
			}
		}
	}
}

exec function StartMatch(string target)
{
	Command_StartMatch(target);
}

function Command_StartMatch(string target)
{
	local Controller C;
	local int namematch;

	if(target=="all")
	{
		for(C=Level.ControllerList; C!=None; C=C.nextController)
		{
			if(C.IsA('PlayerController') || C.IsA('xBot'))
			{
				C.PlayerReplicationInfo.bReadyToPlay=true;
			}
		}

		return;
	}
	else if(target=="")
	{
		target=PlayerReplicationInfo.PlayerName;

		for(C=Level.ControllerList; C!=None; C=C.nextController)
		{
			namematch=InStr(Caps(C.PlayerReplicationInfo.PlayerName), Caps(target)); 

			if(namematch>=0)
			{
				C.PlayerReplicationInfo.bReadyToPlay=true;
			}
		}

		return;
	}
	else
	{
		for(C=Level.ControllerList; C!=None; C=C.nextController)
		{
			if(C.IsA('PlayerController') || C.IsA('xBot'))
			{
				namematch=InStr(Caps(C.PlayerReplicationInfo.PlayerName), Caps(target));

				if(namematch>=0)
				{
					C.PlayerReplicationInfo.bReadyToPlay=true;
				}
			}
		}
	}
}

exec function CustomSummon(string ClassName, int CurrentHealth)
{
	Command_CustomSummon(ClassName,CurrentHealth);
}

exec function CS(string ClassName, int CurrentHealth)
{
	Command_CustomSummon(ClassName,CurrentHealth);
}

function Command_CustomSummon(string ClassName, int CurrentHealth)
{
	local class<actor>NewClass;
	local vector SpawnLoc;
	local actor CurrentActor;

	NewClass=class<actor>(DynamicLoadObject(ClassName, class'Class'));

	if(NewClass!=None)
	{
		if(Pawn!=None)
		{
			SpawnLoc=Pawn.Location;
		}
		else
		{
			SpawnLoc=Location;
		}

		CurrentActor=Spawn(NewClass,,,SpawnLoc+72*Vector(Rotation)+vect(0,0,1)*15);

		if(CurrentActor!=None)
		{
			if(Pawn(CurrentActor)!=none && CurrentHealth>=1)
			{
				Pawn(CurrentActor).Health=CurrentHealth;
				Pawn(CurrentActor).HealthMax=CurrentHealth;
			}
		}
	}
}

exec function CustomAdvancedSummon(string ClassName, string target, int CurrentHealth)
{
	Command_CustomAdvancedSummon(ClassName,target,CurrentHealth);
}

exec function CAS(string ClassName, string target, int CurrentHealth)
{
	Command_CustomAdvancedSummon(ClassName,target,CurrentHealth);
}

function Command_CustomAdvancedSummon(string ClassName, string target, int CurrentHealth)
{
	local class<actor>NewClass;
	local vector SpawnLoc;
	local Pawn p;
	local actor CurrentActor;

	p=verifyTarget(target);

	if(p==None)
	{
		ClientMessage(target @ "is not on the game.");
		return;
	}

	NewClass=class<actor>(DynamicLoadObject(ClassName, class'Class'));

	if(NewClass!=None)
	{
		if(P!=None)
		{
			SpawnLoc=P.Location;
		}
		else
		{
			SpawnLoc=Location;
		}

		CurrentActor=Spawn(NewClass,,,SpawnLoc+72*Vector(Rotation)+vect(0,0,1)*15);

		if(CurrentActor!=None)
		{
			if(Pawn(CurrentActor)!=none && CurrentHealth>=1)
			{
				Pawn(CurrentActor).Health=CurrentHealth;
				Pawn(CurrentActor).HealthMax=CurrentHealth;
			}
		}
	}
}

exec function ZedsPause(bool bPause, optional bool bFullFreeze)
{
	local ID_RPG_Base_GameType RPGGameType;
	local ID_RPG_Base_Monster M;

	RPGGameType=ID_RPG_Base_GameType(Level.Game);

	if(RPGGameType!=none)
	{
		RPGGameType.bZedsPause=bPause;
		RPGGameType.bFullFreeze=bFullFreeze;
	}

	foreach DynamicActors(class'ID_RPG_Base_Monster', M)
	{
		if(M.Health>0)
		{
			Acceleration=vect(0,0,0);
			Velocity.X=0;
			Velocity.Y=0;
			M.bZedsPause=bPause;
			M.bFullFreeze=bFullFreeze;
			M.bShotAnim=bPause || bFullFreeze;

			if(M.Controller!=none && KFMonsterController(M.Controller)!=none)
			{
				KFMonsterController(M.Controller).bUseFreezeHack=bPause || bFullFreeze;
			}
		}
	}
}

exec function SloMo(float T)
{
	ServerSay("Game Speed has been set to" @ T);
	ClientMessage("Use 'SloMo 1' to return to normal");
	Level.Game.SetGameSpeed(T);
}

defaultproperties
{
     MSG_Help1="This is a complete list of commands. (Some may be disabled in the ini)"
     MSG_Help2="Always put admin in front of the command you want. Ex: admin ghost"
     MSG_Help3="Ghost/Walk/Spider/Fly are disabled for bots, it makes them act weird"
     MSG_Help4="MOST COMMANDS CAN BE ISSUED TO OTHERS BY NAME, PARTIAL NAME, or 'ALL'"
     MSG_Help5="Examples: Admin Loaded Brockster, Admin Ghost Broc, Admin Godon All"
     MSG_Help6="--------------------------------------------------------------------------------"
     MSG_Help7="Help - To deduce the information | Ex: ' admin help '"
     MSG_Help8="Slap<target_nick>- Slap the player"
     MSG_Help9="HeadSize<target_name><size>- To change the size of a head of the player (1=to default)"
     MSG_Help10="PlayerSize<target_name><size>- To change the size of the player (1=to default)"
     MSG_Help11="Summon<class>- To cause the monster before itself"
     MSG_Help12="AdvancedSummon<class><target_name>- To cause the monster near to the player"
     MSG_Help13="Respawn<target>- To restore the player or all"
     MSG_Help14="StartMatch<player>"
     MSG_Help15="CustomSummon/CS<class><Health>- To cause the monster before itself with specific modifiers"
     MSG_Help16="CustomAdvancedSummon/CAS<class><target_name><Health>- To cause the monster near to the player with specific modifiers"
     MSG_Help17="ZedsPause<bPause><bFullFreeze>- Stops monsters"
     MSG_ReSpawned="You're back in the game!"
     MSG_ChangeSize="You are experiencing an extreme bodily change."
}
