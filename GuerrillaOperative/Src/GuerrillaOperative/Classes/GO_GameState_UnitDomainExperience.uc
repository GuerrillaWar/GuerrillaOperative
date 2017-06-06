class GO_GameState_UnitDomainExperience extends XComGameState_BaseObject;


struct GO_EarnedAbility {
  var name AbilityName;
  var array<name> ItemCategories;
  var array<name> WeaponCategories;
};

struct GO_UnitDomainStats {
  var int RankPoints;
  var int Experience;
  var name DomainName;
  var array<GO_EarnedAbility> EarnedAbilities;
};


var array<GO_UnitDomainStats> DomainStats;

function InitDomains ()
{
  local X2StrategyElementTemplateManager Manager;
  local array<X2StrategyElementTemplate> Templates;
  local X2StrategyElementTemplate Template;
  local GO_UnitDomainStats Stats, EmptyStats;
  local GO_AbilityDomainTemplate DomainTemplate;
  local int DomainIx;

  Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
  Templates = Manager.GetAllTemplatesOfClass(class'GO_AbilityDomainTemplate');

  foreach Templates(Template)
  {
    DomainTemplate = GO_AbilityDomainTemplate(Template);

    DomainIx = DomainStats.Find('DomainName', DomainTemplate.DataName);

    if (DomainIx == INDEX_NONE)
    {
      Stats = EmptyStats;
      Stats.RankPoints = Rand(7) + 1;
      Stats.Experience = 100;
      Stats.DomainName = DomainTemplate.DataName;
      DomainStats.AddItem(Stats);
    }
  }
}

function GO_UnitDomainStats GetStatsForDomain (name DataName)
{
  local int DomainIx;
  local GO_UnitDomainStats EmptyStats;
  DomainIx = DomainStats.Find('DomainName', DataName);

  if (DomainIx != INDEX_NONE)
  {
    return DomainStats[DomainIx];
  }
  else
  {
    EmptyStats.DomainName = DataName;
    return EmptyStats;
  }
}

function LearnAbilityForDomain(name DomainName, name AbilityName)
{
  local GO_UnitDomainStats Domain;
  local GO_EarnedAbility EarnedAbility;
  local int DomainIx;

  Domain = GetStatsForDomain(DomainName);
  DomainIx = DomainStats.Find('DomainName', DomainName);

  `assert(Domain.RankPoints > 0);
  EarnedAbility.AbilityName = AbilityName;
  DomainStats[DomainIx].EarnedAbilities.AddItem(EarnedAbility);
  DomainStats[DomainIx].RankPoints = Domain.RankPoints - 1;
}
