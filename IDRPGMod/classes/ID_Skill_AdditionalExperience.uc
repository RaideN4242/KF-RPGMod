class ID_Skill_AdditionalExperience extends ID_RPG_Base_Skill_Property;

static function float GetAdditionalExpMulti(ID_RPG_Base_PlayerController Controller)
{
	return GetMulti(GetSkillLevel(Controller));
}

static function float GetMulti(int level)
{
	return level * 0.0034;
}



/*static function float GetMulti(int level)
{
	if ( level < 201) 
		{
		return level * 0.006;
		}
	else if ( level < 401)
		{
		return level * 0.005;
		}
	else if ( level < 601)
		{
		return level * 0.004;
		}
	else if ( level < 801)
		{
		return level * 0.003;
		}	
	else if ( level < 1000)
		{
		return level * 0.002;
		}	
	return level * 0.006;		
}
*/

defaultproperties
{
     ToWhatProperty="to experience per kill"
     Title="Additional Experience"
     Description="Additional experience per kill"
     SkillIndex=15
     MaxLevel=1000
     Icon=Texture'ModIconsRPG.ID_Skill_AdditionalExperience'
}
