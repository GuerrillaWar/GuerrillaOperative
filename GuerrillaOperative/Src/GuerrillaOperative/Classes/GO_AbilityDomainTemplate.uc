class GO_AbilityDomainTemplate extends X2StrategyElementTemplate
  dependson(X2TacticalGameRulesetDataStructures)
  config(ClassData);


struct GO_DomainRank {
  var int ExperienceRequired; // straight combat experience required to earn this
  var int InstructorPointsMultiplier; // how effective training is at reducing the threshold
  var int InstructorPointsCap; // maximum training points that can be applied
  var int TrainingBase; // hours required to train
  var int TrainingInstructorDeduction; // hours deducted by the presence of a trainer
  var array<SoldierClassStatType> StatProgressions;
};

struct GO_DomainItemExperienceData {
  var name WeaponCat;
  var name ItemCat;
  var int XpForKills;
  var int XpForMisses;
  var int XpForHits;
  var int XpForTakingOnMission;
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
var config array<GO_DomainItemExperienceData> ItemExperienceData;

var localized string DisplayName;
var localized string DomainSummary;
