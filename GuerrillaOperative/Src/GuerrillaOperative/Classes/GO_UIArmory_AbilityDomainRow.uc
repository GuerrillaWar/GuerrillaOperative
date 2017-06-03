class GO_UIArmory_AbilityDomainRow extends UIPanel;

var UIText DomainTextName;
var UIList AbilityList;
var array<UIIcon> AbilityIcons;
var GO_AbilityDomainTemplate AbilityDomainTemplate;

simulated function GO_UIArmory_AbilityDomainRow InitDomainRow(
  GO_AbilityDomainTemplate DTemplate
)
{
  local UIIcon AbilityIcon;
  local name AbilityName;
  local X2AbilityTemplateManager Manager;
  local X2AbilityTemplate AbilityTemplate;

  Manager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

  InitPanel();
  AbilityDomainTemplate = DTemplate;
  Navigator.HorizontalNavigation = true;

  `log("Init DomainRow" @ AbilityDomainTemplate.DisplayName);

  DomainTextName = Spawn(class'UIText', self);
  DomainTextName.InitText(,AbilityDomainTemplate.DisplayName);
  DomainTextName.SetHeight(40);
  DomainTextName.SetPosition(10, 10);

  AbilityList = Spawn(class'UIList', self).InitList(
    , 60, 10, 724 - 60, 66, true
  );

  foreach AbilityDomainTemplate.CompetenceAbilities(AbilityName) {
    AbilityTemplate = Manager.FindAbilityTemplate(AbilityName);
    AbilityIcon = UIIcon(AbilityList.CreateItem(class'UIIcon'));
		AbilityIcon.InitIcon(,,,false,42,eUIState_Normal);
    AbilityIcon.LoadIcon(AbilityTemplate.IconImage);
		AbilityIcon.SetForegroundColorState(eUIState_Normal);
  }

  foreach AbilityDomainTemplate.ExpertiseAbilities(AbilityName) {
    AbilityTemplate = Manager.FindAbilityTemplate(AbilityName);
    AbilityIcon = UIIcon(AbilityList.CreateItem(class'UIIcon'));
		AbilityIcon.InitIcon(,,,false,42,eUIState_Normal);
    AbilityIcon.LoadIcon(AbilityTemplate.IconImage);
		AbilityIcon.SetForegroundColorState(eUIState_Normal);
  }

  foreach AbilityDomainTemplate.MasteryAbilities(AbilityName) {
    AbilityTemplate = Manager.FindAbilityTemplate(AbilityName);
    AbilityIcon = UIIcon(AbilityList.CreateItem(class'UIIcon'));
		AbilityIcon.InitIcon(,,,false,42,eUIState_Normal);
    AbilityIcon.LoadIcon(AbilityTemplate.IconImage);
		AbilityIcon.SetForegroundColorState(eUIState_Normal);
  }

  return self;
}



defaultproperties
{
	width = 724;
	height = 76;
	bCascadeFocus = false;
}
