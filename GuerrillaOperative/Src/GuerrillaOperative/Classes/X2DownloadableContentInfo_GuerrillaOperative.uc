class X2DownloadableContentInfo_GuerrillaOperative extends X2DownloadableContentInfo Config(Game);

static event OnPostTemplatesCreated()
{
	`log("GuerrillaOperative :: Present and Correct");
	UpdateTemplatesForGWT();
  CheckDomainTemplates();
  ChainAbilityTag();
}

static event OnPreMission(XComGameState StartState, XComGameState_MissionSite MissionState)
{
  class'GO_TacticalActivityTracker'.static.OnPreMission(StartState, MissionState);
}

static event OnPostMission()
{
  class'GO_TacticalActivityTracker'.static.OnPostMission();
}

static function UpdateTemplatesForGWT()
{
	class'GO_InsertBaseWeaponAbilities'.static.AddBaseAbilitiesToWeapons();
}

static function CheckDomainTemplates ()
{
  local array<X2StrategyElementTemplate> Templates;
  local X2StrategyElementTemplate Template;
  local GO_AbilityDomainTemplate DomainTemplate;
  local GO_AbilityData AbilityData;
  local X2StrategyElementTemplateManager Manager;
  local name AbilityName;

  Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
  Templates = Manager.GetAllTemplatesOfClass(class'GO_AbilityDomainTemplate');

  foreach Templates(Template)
  {
    DomainTemplate = GO_AbilityDomainTemplate(Template);
    `log("Template Name:" @ DomainTemplate.DataName);
    `log("Competence");
    foreach DomainTemplate.CompetenceAbilities(AbilityData)
    {
      `log("-" @ AbilityData.AbilityName);
    }

    `log("Expertise");
    foreach DomainTemplate.ExpertiseAbilities(AbilityData)
    {
      `log("-" @ AbilityData.AbilityName);
    }

    `log("Mastery");
    foreach DomainTemplate.MasteryAbilities(AbilityData)
    {
      `log("-" @ AbilityData.AbilityName);
    }
  }
}



static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local int Index;
  local GO_AbilityDomainTemplate DomainTemplate;
  local AbilitySetupData Setup, BlankSetupData;
  local X2StrategyElementTemplateManager Manager;
  local GO_UnitDomainStats DomainStats;
  local GO_AbilityData AbilityData;
  local GO_EarnedAbility EarnedAbility;
	local X2AbilityTemplateManager AbilityTemplateManager;
  local X2AbilityTemplate AbilityTemplate, SubAbilityTemplate;
  local XComGameState_Item InventoryItem;
  local X2WeaponTemplate WeaponTemplate;
  local name SubAbilityName;
  local array<XComGameState_Item> CurrentInventory;
	local GO_GameState_UnitDomainExperience UnitDomainState;

  UnitDomainState = class'GuerrillaOperativeUtilities'.static.GetUnitDomainExperienceComponent(UnitState);
  Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

  if (UnitDomainState == none) { return; }

  `log("Processing Abilities for Unit");

  foreach UnitDomainState.AllDomainStats(DomainStats)
  {
    DomainTemplate = GO_AbilityDomainTemplate(Manager.FindStrategyElementTemplate(DomainStats.DomainName));
    `log("Domain:" @ DomainStats.DomainName);

    foreach DomainStats.EarnedAbilities(EarnedAbility)
    {
      Setup = BlankSetupData;
      switch (EarnedAbility.Level) {
        case eGO_AbilityLevel_Competence: AbilityData = DomainTemplate.CompetenceAbilities[EarnedAbility.Index]; break;
        case eGO_AbilityLevel_Expertise: AbilityData = DomainTemplate.ExpertiseAbilities[EarnedAbility.Index]; break;
        case eGO_AbilityLevel_Mastery: AbilityData = DomainTemplate.MasteryAbilities[EarnedAbility.Index]; break;
      }
      AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityData.AbilityName);

      if (AbilityData.WeaponCategories.Length > 0) {

        CurrentInventory = UnitState.GetAllInventoryItems(StartState);
        foreach CurrentInventory(InventoryItem)
        {
          WeaponTemplate = X2WeaponTemplate(InventoryItem.GetMyTemplate());
          if (WeaponTemplate != none)
          {
            if (AbilityData.WeaponCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE)
            {
              Setup = BlankSetupData;
              `log("Adding Ability:" @ AbilityData.AbilityName);
              Setup.TemplateName = AbilityData.AbilityName;
              Setup.Template = AbilityTemplate;
              Setup.SourceWeaponRef = InventoryItem.GetReference();
              SetupData.AddItem(Setup);

              foreach AbilityTemplate.AdditionalAbilities(SubAbilityName)
              {
                SubAbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(SubAbilityName);
                Setup = BlankSetupData;
                `log("Adding Ability:" @ SubAbilityName);
                Setup.TemplateName = SubAbilityName;
                Setup.Template = SubAbilityTemplate;
                Setup.SourceWeaponRef = InventoryItem.GetReference();
                SetupData.AddItem(Setup);
              }
            }
          }
        }
      } else if (AbilityData.ItemCategories.Length > 0) {
      } else {
        `log("Adding Ability:" @ AbilityData.AbilityName);
        Setup.TemplateName = AbilityData.AbilityName;
        Setup.Template = AbilityTemplate;
        SetupData.AddItem(Setup);

        foreach AbilityTemplate.AdditionalAbilities(SubAbilityName)
        {
          SubAbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(SubAbilityName);
          Setup = BlankSetupData;
          `log("Adding Ability:" @ SubAbilityName);
          Setup.TemplateName = SubAbilityName;
          Setup.Template = SubAbilityTemplate;
          SetupData.AddItem(Setup);
        }
      }
    }
  }
}


static function ChainAbilityTag()
{
  local XComEngine Engine;
  local GuerrillaOperative_X2AbilityTag AbilityTag;
  local X2AbilityTag OldAbilityTag;
  local int idx;

  Engine = `XENGINE;

  OldAbilityTag = Engine.AbilityTag;

  AbilityTag = new class'GuerrillaOperative_X2AbilityTag';
  AbilityTag.WrappedTag = OldAbilityTag;

  idx = Engine.LocalizeContext.LocalizeTags.Find(Engine.AbilityTag);
  Engine.AbilityTag = AbilityTag;
  Engine.LocalizeContext.LocalizeTags[idx] = AbilityTag;
}
