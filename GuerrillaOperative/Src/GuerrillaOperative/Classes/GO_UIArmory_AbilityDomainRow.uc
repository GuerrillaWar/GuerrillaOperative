class GO_UIArmory_AbilityDomainRow extends UIPanel;

var UIText DomainTextName;
var UIText RankPointsText;
var UIList AbilityList;
var array<UIIcon> CompetenceIcons;
var array<UIIcon> ExpertiseIcons;
var array<UIIcon> MasteryIcons;
var GO_AbilityDomainTemplate AbilityDomainTemplate;
var GO_UnitDomainStats CachedDomainStats;
var UIPanel Experience;
var GO_UIArmory_AbilityDomains ScreenUI;
var bool CompetenceForPurchase, ExpertiseForPurchase, MasteryForPurchase;

simulated function GO_UIArmory_AbilityDomainRow InitDomainRow(
  GO_AbilityDomainTemplate DTemplate
)
{
  local UIIcon AbilityIcon;
  local name AbilityName;
  local X2AbilityTemplateManager Manager;
  local X2AbilityTemplate AbilityTemplate;
  local UIPanel ExperienceBack, ExperienceMin, ExperienceMax;

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

  RankPointsText = Spawn(class'UIText', self);
  RankPointsText.InitText(,"0");
  RankPointsText.SetHeight(20);
  RankPointsText.SetPosition(10, Height - 30);

  AbilityList = Spawn(class'UIList', self).InitList(
    , TextPaddingLeft, PaddingTop, Width - TextPaddingLeft, 66, true
  );
  AbilityList.ItemPadding = 10;

  foreach AbilityDomainTemplate.CompetenceAbilities(AbilityName) {
    AbilityTemplate = Manager.FindAbilityTemplate(AbilityName);
    AbilityIcon = UIIcon(AbilityList.CreateItem(class'UIIcon'));
		AbilityIcon.InitIcon(,,,true,42,eUIState_Disabled);
    AbilityIcon.LoadIcon(AbilityTemplate.IconImage);
		AbilityIcon.SetBGColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
		AbilityIcon.SetForegroundColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
    AbilityIcon.OnMouseEventDelegate = OnAbilityIconEvent;
    CompetenceIcons.AddItem(AbilityIcon);
  }

  foreach AbilityDomainTemplate.ExpertiseAbilities(AbilityName) {
    AbilityTemplate = Manager.FindAbilityTemplate(AbilityName);
    AbilityIcon = UIIcon(AbilityList.CreateItem(class'UIIcon'));
		AbilityIcon.InitIcon(,,,true,42,eUIState_Disabled);
    AbilityIcon.LoadIcon(AbilityTemplate.IconImage);
		AbilityIcon.SetBGColor(class'UIUtilities_Colors'.const.PERK_HTML_COLOR);
		AbilityIcon.SetForegroundColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
    AbilityIcon.OnMouseEventDelegate = OnAbilityIconEvent;
    ExpertiseIcons.AddItem(AbilityIcon);
  }

  foreach AbilityDomainTemplate.MasteryAbilities(AbilityName) {
    AbilityTemplate = Manager.FindAbilityTemplate(AbilityName);
    AbilityIcon = UIIcon(AbilityList.CreateItem(class'UIIcon'));
		AbilityIcon.InitIcon(,,,true,42,eUIState_Disabled);
    AbilityIcon.LoadIcon(AbilityTemplate.IconImage);
		/* AbilityIcon.SetBGColor(class'UIUtilities_Colors'.const.FADED_HTML_COLOR); */
		AbilityIcon.SetForegroundColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
    AbilityIcon.OnMouseEventDelegate = OnAbilityIconEvent;
    MasteryIcons.AddItem(AbilityIcon);
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


simulated function ApplyUnitStats(
  GO_UnitDomainStats DomainStats
)
{
  local int Earned, ToSpend, Ix;
  local bool AbilityEarned;
  local name AbilityName;
  local UIIcon AbilityIcon;

  CachedDomainStats = DomainStats;
  Earned = DomainStats.EarnedAbilities.Length;
  ToSpend = DomainStats.RankPoints;

  RankPointsText.SetText("" $ ToSpend);

  if (Earned >= 6 && ToSpend > 0)
  {
    MasteryForPurchase = true;
    ExpertiseForPurchase = false;
    CompetenceForPurchase = false;
  }
  else if (Earned >= 4 && ToSpend > 0)
  {
    ExpertiseForPurchase = true;
    CompetenceForPurchase = false;
    MasteryForPurchase = false;
  }
  else if (ToSpend > 0)
  {
    CompetenceForPurchase = true;
    ExpertiseForPurchase = false;
    MasteryForPurchase = false;
  }
  else
  {
    CompetenceForPurchase = false;
    ExpertiseForPurchase = false;
    MasteryForPurchase = false;
  }

  foreach AbilityDomainTemplate.CompetenceAbilities(AbilityName, Ix) {
    AbilityIcon = CompetenceIcons[Ix];
    AbilityEarned = (
      DomainStats.EarnedAbilities.Find('AbilityName', AbilityName) != INDEX_NONE
    );

    SetAbilityIconColor(AbilityIcon, AbilityEarned, CompetenceForPurchase);
  }

  foreach AbilityDomainTemplate.ExpertiseAbilities(AbilityName, Ix) {
    AbilityIcon = ExpertiseIcons[Ix];
    AbilityEarned = (
      DomainStats.EarnedAbilities.Find('AbilityName', AbilityName) != INDEX_NONE
    );

    SetAbilityIconColor(AbilityIcon, AbilityEarned, ExpertiseForPurchase);
  }

  foreach AbilityDomainTemplate.MasteryAbilities(AbilityName, Ix) {
    AbilityIcon = MasteryIcons[Ix];
    AbilityEarned = (
      DomainStats.EarnedAbilities.Find('AbilityName', AbilityName) != INDEX_NONE
    );

    SetAbilityIconColor(AbilityIcon, AbilityEarned, MasteryForPurchase);
  }
}

function SetAbilityIconColor(UIIcon AbilityIcon, bool Earned, bool Available)
{
  if (Earned)
  {
    AbilityIcon.SetBGColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
  }
  else if (Available)
  {
    AbilityIcon.SetBGColor(class'UIUtilities_Colors'.const.PERK_HTML_COLOR);
  }
  else
  {
    AbilityIcon.SetBGColor(class'UIUtilities_Colors'.const.DISABLED_HTML_COLOR);
  }
}

simulated function OnAbilityIconEvent(UIPanel Panel, int Cmd)
{
  local UIIcon AbilityIcon;
  local int AbilityIx;
  local name AbilityName;
  local bool AbilityEarned;

  AbilityIcon = UIIcon(Panel);
	if (Cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_DOWN)
  {
    AbilityIx = CompetenceIcons.Find(AbilityIcon);
    if (AbilityIx != INDEX_NONE && CompetenceForPurchase)
    {
      AbilityName = AbilityDomainTemplate.CompetenceAbilities[AbilityIx];
      AbilityEarned = (
        CachedDomainStats.EarnedAbilities.Find('AbilityName', AbilityName) != INDEX_NONE
      );

      if (!AbilityEarned)
      {
        ScreenUI.LearnDomainAbility(AbilityDomainTemplate.DataName, AbilityName);
      }
    }

    AbilityIx = ExpertiseIcons.Find(AbilityIcon);
    if (AbilityIx != INDEX_NONE && ExpertiseForPurchase)
    {
      AbilityName = AbilityDomainTemplate.ExpertiseAbilities[AbilityIx];
      AbilityEarned = (
        CachedDomainStats.EarnedAbilities.Find('AbilityName', AbilityName) != INDEX_NONE
      );

      if (!AbilityEarned)
      {
        ScreenUI.LearnDomainAbility(AbilityDomainTemplate.DataName, AbilityName);
      }
    }

    AbilityIx = MasteryIcons.Find(AbilityIcon);
    if (AbilityIx != INDEX_NONE && MasteryForPurchase)
    {
      AbilityName = AbilityDomainTemplate.MasteryAbilities[AbilityIx];
      AbilityEarned = (
        CachedDomainStats.EarnedAbilities.Find('AbilityName', AbilityName) != INDEX_NONE
      );

      if (!AbilityEarned)
      {
        ScreenUI.LearnDomainAbility(AbilityDomainTemplate.DataName, AbilityName);
      }
    }
  }
}

defaultproperties
{
	width = 650;
	height = 76;
	bCascadeFocus = false;
}
