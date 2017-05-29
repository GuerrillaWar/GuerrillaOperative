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


var config array<name> CompetenceAbilities;
var config array<name> ExpertiseAbilities;
var config array<name> MasteryAbilities;
var config array<GO_DomainRank> DomainRanks;

var localized string DisplayName;
var localized string DomainSummary;
