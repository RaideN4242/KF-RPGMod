class ID_Skill_Discount extends ID_RPG_Base_Skill_Property;

static function float GetReduceCostMulti(ID_RPG_Stats_ReplicationLink Link, class<Pickup> Pickup)
{
	if(Pickup!=None && (InStr(string(Pickup),"CivNadePickup")>=0 || InStr(string(Pickup),"VestRPG")>=0 || InStr(string(Pickup),"M32Pro")>=0 || InStr(string(Pickup),"EBRPro")>=0
		|| InStr(string(Pickup),"Petrolboomer")>=0) )	
		return 0;
	
	if(Pickup==None || InStr(string(Pickup),"P416")>=0 || InStr(string(Pickup),"MP7D")>=0 || InStr(string(Pickup),"MP7M")>=0 || InStr(string(Pickup),"6")<0 && InStr(string(Pickup),"7")<0 )
		return GetMulti(GetSkillLevel(Link));
	else
		return 0;
}

static function float GetMulti(int level)
{	
	return level * 0.0003;
}

defaultproperties
{
     ToWhatProperty="to discount"
     Title="Discount"
     Description="Discount in shop."
     SkillIndex=3
     MaxLevel=3000
     Icon=Texture'ModIconsRPG.ID_Skill_Discount'
}
