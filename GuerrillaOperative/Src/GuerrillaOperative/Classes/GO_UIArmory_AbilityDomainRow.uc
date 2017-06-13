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
  local GO_AbilityData AbilityData;
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

  foreach AbilityDomainTemplate.CompetenceAbilities(AbilityData) {
    AbilityName = AbilityData.AbilityName;
    AbilityTemplate = Manager.FindAbilityTemplate(AbilityName);
    AbilityIcon = UIIcon(AbilityList.CreateItem(class'UIIcon'));
		AbilityIcon.InitIcon(,,,true,42,eUIState_Disabled);
    AbilityIcon.LoadIcon(AbilityTemplate.IconImage);
		AbilityIcon.SetBGColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
		AbilityIcon.SetForegroundColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
    AbilityIcon.OnMouseEventDelegate = OnAbilityIconEvent;
    CompetenceIcons.AddItem(AbilityIcon);
  }

  foreach AbilityDomainTemplate.ExpertiseAbilities(AbilityData) {
    AbilityName = AbilityData.AbilityName;
    AbilityTemplate = Manager.FindAbilityTemplate(AbilityName);
    AbilityIcon = UIIcon(AbilityList.CreateItem(class'UIIcon'));
		AbilityIcon.InitIcon(,,,true,42,eUIState_Disabled);
    AbilityIcon.LoadIcon(AbilityTemplate.IconImage);
		AbilityIcon.SetBGColor(class'UIUtilities_Colors'.const.PERK_HTML_COLOR);
		AbilityIcon.SetForegroundColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
    AbilityIcon.OnMouseEventDelegate = OnAbilityIconEvent;
    ExpertiseIcons.AddItem(AbilityIcon);
  }

  foreach AbilityDomainTemplate.MasteryAbilities(AbilityData) {
    AbilityName = AbilityData.AbilityName;
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
  local GO_EarnedAbility EarnedAbilityIter;
  local name AbilityName;
  local GO_AbilityData AbilityData;
  local UIIcon AbilityIcon;
  local int TextPaddingLeft, PaddingRight, FullExpWidth, ExpRequired, ExpWidth;

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

  TextPaddingLeft = 160;
  PaddingRight = 20;
  FullExpWidth = Width - TextPaddingLeft - PaddingRight;

  `log(AbilityDomainTemplate.DataName $ ":" @ DomainStats.Experience $ "xp");

  if (Earned + ToSpend < 7)
  {
    ExpRequired = AbilityDomainTemplate.DomainRanks[Earned + ToSpend].ExperienceRequired;
    ExpWidth = Round((float(DomainStats.Experience) / float(ExpRequired)) * float(FullExpWidth));
    `log(DomainStats.Experience @ "/" @ ExpRequired @ "*" @ FullExpWidth);
    `log("XpWidth:" @ ExpWidth);
    Experience.SetSize(ExpWidth, 2);
    Experience.SetColor( class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
  }
  else
  {
    Experience.SetSize(FullExpWidth, 2);
    Experience.SetColor( class'UIUtilities_Colors'.const.PERK_HTML_COLOR);
  }

  foreach AbilityDomainTemplate.CompetenceAbilities(AbilityData, Ix) {
    AbilityIcon = CompetenceIcons[Ix];
    AbilityEarned = false;
    foreach DomainStats.EarnedAbilities(EarnedAbilityIter) {
      if (EarnedAbilityIter.Index == Ix && EarnedAbilityIter.Level == eGO_AbilityLevel_Competence) {
        AbilityEarned = true;
      }
    }

    SetAbilityIconColor(AbilityIcon, AbilityEarned, CompetenceForPurchase);
  }

  foreach AbilityDomainTemplate.ExpertiseAbilities(AbilityData, Ix) {
    AbilityIcon = ExpertiseIcons[Ix];
    AbilityEarned = false;
    foreach DomainStats.EarnedAbilities(EarnedAbilityIter) {
      if (EarnedAbilityIter.Index == Ix && EarnedAbilityIter.Level == eGO_AbilityLevel_Expertise) {
        AbilityEarned = true;
      }
    }

    SetAbilityIconColor(AbilityIcon, AbilityEarned, ExpertiseForPurchase);
  }

  foreach AbilityDomainTemplate.MasteryAbilities(AbilityData, Ix) {
    AbilityIcon = MasteryIcons[Ix];
    AbilityEarned = false;
    foreach DomainStats.EarnedAbilities(EarnedAbilityIter) {
      if (EarnedAbilityIter.Index == Ix && EarnedAbilityIter.Level == eGO_AbilityLevel_Mastery) {
        AbilityEarned = true;
      }
    }

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
  local GO_EarnedAbility EarnedAbilityIter;
  local bool AbilityEarned;

  AbilityIcon = UIIcon(Panel);
	if (Cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_DOWN)
  {
    AbilityIx = CompetenceIcons.Find(AbilityIcon);
    AbilityEarned = false;
    if (AbilityIx != INDEX_NONE && CompetenceForPurchase)
    {
      foreach CachedDomainStats.EarnedAbilities(EarnedAbilityIter) {
        if (EarnedAbilityIter.Index == AbilityIx && EarnedAbilityIter.Level == eGO_AbilityLevel_Competence) {
          AbilityEarned = true;
        }
      }

      if (!AbilityEarned)
      {
        ScreenUI.LearnDomainAbility(AbilityDomainTemplate.DataName, eGO_AbilityLevel_Competence, AbilityIx);
      }
    }

    AbilityIx = ExpertiseIcons.Find(AbilityIcon);
    if (AbilityIx != INDEX_NONE && ExpertiseForPurchase)
    {
      foreach CachedDomainStats.EarnedAbilities(EarnedAbilityIter) {
        if (EarnedAbilityIter.Index == AbilityIx && EarnedAbilityIter.Level == eGO_AbilityLevel_Expertise) {
          AbilityEarned = true;
        }
      }

      if (!AbilityEarned)
      {
        ScreenUI.LearnDomainAbility(AbilityDomainTemplate.DataName, eGO_AbilityLevel_Expertise, AbilityIx);
      }
    }

    AbilityIx = MasteryIcons.Find(AbilityIcon);
    if (AbilityIx != INDEX_NONE && MasteryForPurchase)
    {
      foreach CachedDomainStats.EarnedAbilities(EarnedAbilityIter) {
        if (EarnedAbilityIter.Index == AbilityIx && EarnedAbilityIter.Level == eGO_AbilityLevel_Mastery) {
          AbilityEarned = true;
        }
      }

      if (!AbilityEarned)
      {
        ScreenUI.LearnDomainAbility(AbilityDomainTemplate.DataName, eGO_AbilityLevel_Mastery, AbilityIx);
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
