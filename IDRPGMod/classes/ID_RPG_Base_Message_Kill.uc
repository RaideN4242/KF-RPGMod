Class ID_RPG_Base_Message_Kill extends LocalMessage;

var localized string KillString, KillsString;
var localized float MessageShowTime;

static final function string GetNameOf( class<Monster> M )
{
	if( Len(M.Default.MenuName)==0 )
		return string(M.Name);
	return M.Default.MenuName;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return "+"$(Switch+1)@GetNameOf(Class<Monster>(OptionalObject))@Eval(Switch==0,Default.KillString,Default.KillsString);
}

static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local ID_HUD H;
	local byte i;
	local ID_HUD.HudLocalizedMessage  Messages[8];

	if( Class<Monster>(OptionalObject)==None || ID_HUD(P.myHud)==None )
		return;
	H = ID_HUD(P.myHud);
	H.GetLocalizedMessages(Messages);
	for( i=0; i<8; ++i )
	{
		if( Messages[i].Message==Default.Class)
		{
			if ( Messages[i].OptionalObject==OptionalObject)
			{
				++Messages[i].Switch;
				Messages[i].DrawColor = GetColor(Messages[i].Switch);
				Messages[i].LifeTime = Default.MessageShowTime;
				Messages[i].EndOfLife = Default.MessageShowTime + P.Level.TimeSeconds;
				Messages[i].StringMessage = GetString(Messages[i].Switch,,,OptionalObject);
				H.SetLocalizedMessage(Messages[i], i);
				return;
			}
		}
	}
	P.myHUD.LocalizedMessage(Default.Class,0,,,OptionalObject);
}

static function float GetLifeTime(int Switch)
{
	return default.MessageShowTime;
}

// Fade color: Green (0-3 frags) > Yellow (4-7 frags) > Red (8-12 frags) > Dark Red (13+ frags).
static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	local color C;

	C.A = 255;
	if( Switch<10 )
	{
		C.G = Clamp(500-Switch*50,0,255);
		C.R = Clamp(0+Switch*50,0,255);
	}
	else C.R = Max(505-Switch*25,150);
	return C;
}

defaultproperties
{
     KillString="kill"
     KillsString="kills"
     MessageShowTime=2.500000
     bIsConsoleMessage=False
     bFadeMessage=True
     DrawColor=(B=0,G=0,R=150)
     DrawPivot=DP_UpperLeft
     StackMode=SM_Down
     PosX=0.020000
     PosY=0.200000
}
