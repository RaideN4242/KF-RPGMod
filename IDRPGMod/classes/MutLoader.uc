class MutLoader extends Mutator
	config (MutLoader);

var() config array<string> Mutator;
var() config bool bDebug;
var bool bInitialized;

function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
        local int i,N;
        N = ServerState.ServerInfo.Length;
        if(N<2) return;
        for(i=0;i<N;i++)
        {
                if(ServerState.ServerInfo[i].Key ~= "Mutator")
                {
                        ServerState.ServerInfo[i].Value="Hidden";
                }
        }
}

simulated function PostBeginPlay()
{
	SaveConfig();
	Super.PostBeginPlay();
}

function PreBeginPlay()
{
	local int i;
	Super.PreBeginPlay();
	
	if (bInitialized) return;
        bInitialized = True;
		
	for( i=(Mutator.Length-1); i>=0; --i )
	{
		if ((Mutator[i] == "") || (Mutator[i] == "IDRPGMod.MutLoader"))
			continue;
		else
		{
			//Super.AddMutator(Mutators[i]);//Level.Game.AddMutator(Other);
			Level.Game.AddMutator(Mutator[i],true);
			if (bDebug)
				log("mut.added"@Mutator[i]);	
		}
	}
    return;
}

defaultproperties
{
	bDebug=true
}
