class GO_GameState_UnitDomainExperience extends XComGameState_BaseObject;

enum eGO_AbilityLevel {
  eGO_AbilityLevel_Competence,
  eGO_AbilityLevel_Expertise,
  eGO_AbilityLevel_Mastery,
};


struct GO_EarnedAbility {
  var eGO_AbilityLevel Level;
  var int Index;

  structdefaultproperties {
    Index = -1;
  }
};


struct GO_UnitDomainStats {
  var int RankPoints;
  var int Experience;
  var name DomainName;
  var array<GO_EarnedAbility> EarnedAbilities;
};


var array<GO_UnitDomainStats> AllDomainStats;

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

    DomainIx = AllDomainStats.Find('DomainName', DomainTemplate.DataName);

    if (DomainIx == INDEX_NONE)
    {
      Stats = EmptyStats;
      Stats.RankPoints = 7;
      Stats.Experience = 0;
      Stats.DomainName = DomainTemplate.DataName;
      AllDomainStats.AddItem(Stats);
    }
  }
}

function GO_UnitDomainStats GetStatsForDomain (name DataName)
{
  local int DomainIx;
  local GO_UnitDomainStats EmptyStats;
  DomainIx = AllDomainStats.Find('DomainName', DataName);

  if (DomainIx != INDEX_NONE)
  {
    return AllDomainStats[DomainIx];
  }
  else
  {
    EmptyStats.DomainName = DataName;
    return EmptyStats;
  }
}

function LearnAbilityForDomain(
  name DomainName, eGO_AbilityLevel AbilityLevel, int AbilityIx
)
{
  local GO_UnitDomainStats Domain;
  local GO_EarnedAbility EarnedAbility;
  local int DomainIx;

  Domain = GetStatsForDomain(DomainName);
  DomainIx = AllDomainStats.Find('DomainName', DomainName);

  `assert(Domain.RankPoints > 0);
  EarnedAbility.Level = AbilityLevel;
  EarnedAbility.Index = AbilityIx;
  AllDomainStats[DomainIx].EarnedAbilities.AddItem(EarnedAbility);
  AllDomainStats[DomainIx].RankPoints = Domain.RankPoints - 1;
}
