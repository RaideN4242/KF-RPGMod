class ID_Skill_AdditionalCash extends ID_RPG_Base_Skill_Property;

static function float GetAdditionalCashMulti(ID_RPG_Base_PlayerController Controller)
{
	return GetMulti(GetSkillLevel(Controller));
}

static function float GetMulti(int level)
{
	return level * 0.0029;
}

/*static function float GetMulti(int level)
{
	if ( level < 21) // ***
		{
		return level * 0.06;
		}
	else if ( level < 41)
		{
		return level * 0.05;
		}
	else if ( level < 61)
		{
		return level * 0.04;
		}
	else if ( level < 81)
		{
		return level * 0.03;
		}	
	else if ( level < 101)
		{
		return level * 0.02;
		}	
	return level * 0.05;
}*/

defaultproperties
{
     ToWhatProperty="to cash per kill"
     Title="Additional Cash"
     Description="Additional cash per kill"
     SkillIndex=16
     MaxLevel=99999
     Icon=Texture'ModIconsRPG.ID_Skill_AdditionalCash'
}
