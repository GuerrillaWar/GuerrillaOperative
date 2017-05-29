class X2DownloadableContentInfo_GuerrillaOperative extends X2DownloadableContentInfo Config(Game);

static event OnPostTemplatesCreated()
{
	`log("GuerrillaOperative :: Present and Correct");
	UpdateTemplatesForGWT();
  CheckDomainTemplates();

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
  local X2StrategyElementTemplateManager Manager;
  local name AbilityName;

  Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
  Templates = Manager.GetAllTemplatesOfClass(class'GO_AbilityDomainTemplate');

  foreach Templates(Template)
  {
    DomainTemplate = GO_AbilityDomainTemplate(Template);
    `log("Template Name:" @ DomainTemplate.DataName);
    `log("Competence");
    foreach DomainTemplate.CompetenceAbilities(AbilityName)
    {
      `log("-" @ AbilityName);
    }

    `log("Expertise");
    foreach DomainTemplate.ExpertiseAbilities(AbilityName)
    {
      `log("-" @ AbilityName);
    }

    `log("Mastery");
    foreach DomainTemplate.MasteryAbilities(AbilityName)
    {
      `log("-" @ AbilityName);
    }
  }
}
