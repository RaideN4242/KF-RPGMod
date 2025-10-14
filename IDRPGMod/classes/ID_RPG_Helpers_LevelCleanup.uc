Class ID_RPG_Helpers_LevelCleanup extends Interaction;

function NotifyLevelChange()
{
	local int i;

	for( i=(ViewportOwner.LocalInteractions.Length-1); i>=0; --i )
		if( ViewportOwner.LocalInteractions[i]==Self )
			ViewportOwner.LocalInteractions.Remove(i,1);
	ViewportOwner.Console.DelayedConsoleCommand("OBJ GARBAGE"); // Ensure to cleanup everything releated to this mod.
}

static final function AddSafeCleanup( PlayerController PC )
{
	local int i;
	local ID_RPG_Helpers_LevelCleanup C;

	for( i=(PC.Player.LocalInteractions.Length-1); i>=0; --i )
		if( PC.Player.LocalInteractions[i].Class==Default.Class )
			return;
	C = new(None) Class'ID_RPG_Helpers_LevelCleanup';
	C.ViewportOwner = PC.Player;
	C.Master = PC.Player.InteractionMaster;
	i = PC.Player.LocalInteractions.Length;
	PC.Player.LocalInteractions.Length = i+1;
	PC.Player.LocalInteractions[i] = C;
	C.Initialize();
}

defaultproperties
{
}
