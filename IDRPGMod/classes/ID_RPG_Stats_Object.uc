Class ID_RPG_Stats_Object extends Object
	PerObjectConfig
	Config(ServerPerksStat);

var config string PlayerName,PlayerIP;
var config string Experience;
var config int Skills[51];

var int ID;
var bool bStatsChanged;

final function string GetSelectedPerk()
{
	//if( InStr(SelectedVeterancy,".")==-1 )
	//	return string(Class.Outer.Name)$"."$SelectedVeterancy;
	return "IDPRGMod.ID_RPG_Stats_Veterancy"; //SelectedVeterancy;
}

final function string GetSaveData()
{
	local string Result;
	local int i;

	Result = "" $ Experience;
	for (i = 0; i < ArrayCount(Skills); i++)
		Result $= "," $ Skills[i];

	return Result;
}
static final function int GetNextValue(out string S)
{
	local int i,Result;

	i = InStr(S,",");
	if( i==-1 )
	{
		Result = int(S);
		S = "";
	}
	else
	{
		Result = int(Left(S,i));
		S = Mid(S,i+1);
	}
	return Result;
}

static final function string GetNextStrValue(out string S)
{
	local int i;
	local string Result;

	i=InStr(S,",");

	if(i==-1)
	{
		if(Left(S,1)=="'")
		{
			Result = Mid(S,1,Len(S)-2);
		}

		S="";
	}
	else if(Left(S,1)=="'" && Mid(S,i-1,1)=="'")
	{
		Result = Mid(S,1,i-2);
		S=Mid(S,i+1);
	}
	else
	{
		Result = Left(S,i);
		S=Mid(S,i+1);
	}

	return Result;
}

final function SetSaveData(string S)
{
	local int i;
	local int currentPerk;

	i = InStr(S,",");
	if( i==-1 )
		return;
	Experience = GetNextStrValue(S);
	for (i = 0; i < ArrayCount(Skills); i++)
	{
		currentPerk = GetNextValue(S);
		if (currentPerk < 0)
			currentPerk = 0;
		Skills[i] = currentPerk;
	}
}

defaultproperties
{
     id=-1
}
