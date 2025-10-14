class ID_Skill_DecreasedRecoil extends ID_RPG_Base_Skill_Property;

static function float GetRecoilDecreaseMulti(ID_RPG_Base_HumanPawn Player, ID_RPG_Base_Weapon Weapon)
{
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	return level * 0.05;
}

defaultproperties
{
     ToWhatProperty="to recoil reduction"
     Title="Recoil"
     Description="Decrease recoil from all weapons."
     SkillIndex=5
     MaxLevel=20
     Icon=Texture'ModIconsRPG.ID_Skill_DecreasedRecoil'
}
