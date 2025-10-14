class ID_RPG_Base_Skill_Property extends ID_RPG_Base_Skill;

var string ToWhatProperty;
var string PlusMinus;
var bool IsPercent;

static function string GetCurrentSkillInfoInternal(int level)
{
	return GetInfoInternal(GetMulti(level));
}

static function string GetNextSkillInfoInternal(int level)
{
	return GetCurrentSkillInfoInternal(level);
}

static function float GetMulti(int level)
{
	return level * 0.03;
}

static function string GetInfoInternal(float value)
{
	return default.PlusMinus $ Eval(default.IsPercent, ToPercent(value), int(value)) @ default.ToWhatProperty;
}

defaultproperties
{
     ToWhatProperty="to damage"
     PlusMinus="+"
     IsPercent=True
     Title="Damage"
     Description="Increased damage from all weapons."
}
