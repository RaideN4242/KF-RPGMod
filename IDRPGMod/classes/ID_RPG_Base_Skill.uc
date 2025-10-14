class ID_RPG_Base_Skill extends Info abstract;

var string Title;
var string Description;
var string DontHaveThisSkill;
var int SkillIndex;
var int MaxLevel;
var texture Icon; 
var string InitialCost;
var string PerLevelCost;
var string AdditionalCost;

static function string AddNumericValuesFromStrings(string S, string SS)
{
	return class'USB_Commands'.static.AddNumericValuesFromStrings(S,SS);
}

static function string MultiplyNumericValuesFromStrings(string S, string SS)
{
	return class'USB_Commands'.static.MultiplyNumericValuesFromStrings(S,SS);
}

static function string ClampNumericValueFromStrings(string S, string SS, string SSS)
{
	return class'USB_Commands'.static.ClampNumericValueFromStrings(S,SS,SSS);
}

static function string GetCurrentSkillInfo(ID_RPG_Stats_ReplicationLink Link)
{
	local int level;
	level = GetSkillLevel(Link);
	if (level == 0)
		return default.DontHaveThisSkill;
	return GetCurrentSkillInfoInternal(level);
}

static function string GetCurrentSkillInfoInternal(int level)
{
	return default.Description;
}

static function string GetNextLevelSkillInfo(ID_RPG_Stats_ReplicationLink Link)
{
	return GetNextSkillInfoInternal(static.GetSkillLevel(Link) + 1);
}

static function string GetNextSkillInfoInternal(int level)
{
	return default.Description;
}

static function string GetSkillTitle(ID_RPG_Stats_ReplicationLink Link)
{
	return default.Title;
}

static function string ToPercent(float value)
{
	return value * 100 $ "%";
}

static function int GetSkillLevel(Object from)
{
	if (ID_RPG_Stats_ReplicationLink(from) != none)
		return ID_RPG_Stats_ReplicationLink(from).Skills[default.SkillIndex];
	if (ID_RPG_Base_HumanPawn(from) != none)
		return ID_RPG_Base_HumanPawn(from).getRepLink().Skills[default.SkillIndex];
	if (ID_RPG_Base_PlayerController(from) != none)
		return ID_RPG_Base_PlayerController(from).getRepLink().Skills[default.SkillIndex];
}

static function string GetNextLevelPrice(ID_RPG_Stats_ReplicationLink Link)
{
	return GetNextLevelPriceInternal(static.GetSkillLevel(Link) + 1);
}

static function string GetNextLevelPriceInternal(int nextLevel)
{
	return ClampNumericValueFromStrings(AddNumericValuesFromStrings(default.InitialCost,MultiplyNumericValuesFromStrings((
		AddNumericValuesFromStrings(default.PerLevelCost,MultiplyNumericValuesFromStrings(default.AdditionalCost,
		string(nextLevel-1)))),string(nextLevel-1))),"0","500000000");
}

defaultproperties
{
     Title="Abstract Skill"
     Description="Abstract Skill description"
     DontHaveThisSkill="You don't have this skill yet"
     MaxLevel=50000
     Icon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Support_Gold'
     InitialCost="1000"
     PerLevelCost="1500"
     AdditionalCost="500"
}
