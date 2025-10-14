class ID_RPG_Misc_Bleeder_Item extends Inventory config(IDRPGMod);

var globalconfig int Damage;
var globalconfig int Interval;
var globalconfig int Count;
var globalconfig int BleedingHealthTreshold;

var int counter;

function GiveTo( pawn Other, optional Pickup Pickup )
{
	Instigator = Other;
	if ( Other.AddInventory( Self ) )
		GotoState('Bleeding');
	else Destroy();
}

State Bleeding
{
	final function TakeBleedingDamage()
	{
		Instigator.TakeDamage(Damage,None,vect(0,0,0),vect(0,0,0),Class'ID_RPG_Misc_Bleeder_DamageType');
		if( Instigator!=None )
		{
			Spawn(Class'ROEffects.ROBloodPuff',,, Instigator.Location);
		}
	}
Begin:
	for( counter=0; counter<Count; counter++ )
	{
		Sleep(Interval);
		if (Instigator == none || Instigator.Health < 0 ||Instigator.Health > BleedingHealthTreshold * 1.3)
			break;
		TakeBleedingDamage();
		BroadcastLocalizedMessage(Class'ID_RPG_Misc_Bleeder_Message',,Instigator.PlayerReplicationInfo);
	}
	Destroy();
}

defaultproperties
{
     Damage=1
     Interval=2
     Count=15
     BleedingHealthTreshold=20
}
