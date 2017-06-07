class GO_AbilityDomainTemplate extends X2StrategyElementTemplate
  dependson(X2TacticalGameRulesetDataStructures)
  config(ClassData);


struct GO_DomainRank {
  var int ExperienceRequired;
  var int InstructorPointsMultiplier;
  var int InstructorPointsCap;
  var int TrainingBase;
  var int TrainingInstructorDeduction;
  var array<SoldierClassStatType> StatProgressions;
};

struct GO_AbilityData {
  var name AbilityName;
  var array<name> ItemCategories;
  var array<name> WeaponCategories;
};

var config array<GO_AbilityData> CompetenceAbilities;
var config array<GO_AbilityData> ExpertiseAbilities;
var config array<GO_AbilityData> MasteryAbilities;
var config array<GO_DomainRank> DomainRanks;

var localized string DisplayName;
var localized string DomainSummary;
