class GO_UIArmory_AbilityDomainRow extends UIPanel;

var UIText DomainTextName;
var UIList AbilityList;
var array<UIIcon> AbilityIcons;
var GO_AbilityDomainTemplate AbilityDomainTemplate;

simulated function GO_UIArmory_AbilityDomainRow InitDomainRow(
  GO_AbilityDomainTemplate DTemplate,
  GO_UnitDomainStats DomainStats
)
{
  local UIIcon AbilityIcon;
  local name AbilityName;
  local X2AbilityTemplateManager Manager;
  local X2AbilityTemplate AbilityTemplate;
  local UIPanel Experience, ExperienceBack, ExperienceMin, ExperienceMax;

  local int TextPaddingLeft, PaddingTop, PaddingBottom, PaddingRight;
  local int TickHeight;

  TextPaddingLeft = 160;
  PaddingTop = 10;
  PaddingRight = 20;
  PaddingBottom = 10;
  TickHeight = 8;

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
    , TextPaddingLeft, PaddingTop, Width - TextPaddingLeft, 66, true
  );
  AbilityList.ItemPadding = 5;

  foreach AbilityDomainTemplate.CompetenceAbilities(AbilityName) {
    AbilityTemplate = Manager.FindAbilityTemplate(AbilityName);
    AbilityIcon = UIIcon(AbilityList.CreateItem(class'UIIcon'));
		AbilityIcon.InitIcon(,,,true,42,eUIState_Warning);
    AbilityIcon.LoadIcon(AbilityTemplate.IconImage);
		AbilityIcon.SetBGColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
		AbilityIcon.SetForegroundColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
  }

  foreach AbilityDomainTemplate.ExpertiseAbilities(AbilityName) {
    AbilityTemplate = Manager.FindAbilityTemplate(AbilityName);
    AbilityIcon = UIIcon(AbilityList.CreateItem(class'UIIcon'));
		AbilityIcon.InitIcon(,,,true,42,eUIState_Disabled);
    AbilityIcon.LoadIcon(AbilityTemplate.IconImage);
		AbilityIcon.SetBGColor(class'UIUtilities_Colors'.const.PERK_HTML_COLOR);
		AbilityIcon.SetForegroundColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
  }

  foreach AbilityDomainTemplate.MasteryAbilities(AbilityName) {
    AbilityTemplate = Manager.FindAbilityTemplate(AbilityName);
    AbilityIcon = UIIcon(AbilityList.CreateItem(class'UIIcon'));
		AbilityIcon.InitIcon(,,,true,42,eUIState_Disabled);
    AbilityIcon.LoadIcon(AbilityTemplate.IconImage);
		/* AbilityIcon.SetBGColor(class'UIUtilities_Colors'.const.FADED_HTML_COLOR); */
		AbilityIcon.SetForegroundColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
  }

  ExperienceBack = Spawn(class'UIPanel', self).InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel);
	ExperienceBack.SetPosition(TextPaddingLeft, Height - PaddingBottom);
	ExperienceBack.SetSize(Width - TextPaddingLeft - PaddingRight, 2);
	ExperienceBack.SetColor( class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	ExperienceBack.SetAlpha( 15 );

  Experience = Spawn(class'UIPanel', self).InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel);
	Experience.SetPosition(TextPaddingLeft, Height - PaddingBottom);
	Experience.SetSize(100, 2); // eventually calced
	Experience.SetColor( class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);

  ExperienceMin = Spawn(class'UIPanel', self).InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel);
	ExperienceMin.SetPosition(TextPaddingLeft, Height - PaddingBottom - (TickHeight / 2) + 1);
	ExperienceMin.SetSize(2, TickHeight); // eventually calced
	ExperienceMin.SetColor( class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);

  ExperienceMax = Spawn(class'UIPanel', self).InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel);
	ExperienceMax.SetPosition(Width - PaddingRight, Height - PaddingBottom - (TickHeight / 2) + 1);
	ExperienceMax.SetSize(2, TickHeight); // eventually calced
	ExperienceMax.SetColor( class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	ExperienceMax.SetAlpha( 15 );




  return self;
}



defaultproperties
{
	width = 650;
	height = 76;
	bCascadeFocus = false;
}
