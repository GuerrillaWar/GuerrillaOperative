class GO_UIArmory_AbilityDomains extends UIArmory_Promotion;



var localized string strScreenTitle;


delegate OnDomainAbilityLearn(name AbilityName, name DomainName);

simulated function InitPromotion(StateObjectReference UnitRef, optional bool bInstantTransition)
{
	// If the AfterAction screen is running, let it position the camera
	AfterActionScreen = UIAfterAction(Movie.Stack.GetScreen(class'UIAfterAction'));
	if(AfterActionScreen != none)
	{
		bAfterActionPromotion = true;
		PawnLocationTag = AfterActionScreen.GetPawnLocationTag(UnitRef);
		CameraTag = AfterActionScreen.GetPromotionBlueprintTag(UnitRef);
		DisplayTag = name(AfterActionScreen.GetPromotionBlueprintTag(UnitRef));
	}
	else
	{
		CameraTag = GetPromotionBlueprintTag(UnitRef);
		DisplayTag = name(GetPromotionBlueprintTag(UnitRef));
	}
	
	// Don't show nav help during tutorial, or during the After Action sequence.
	bUseNavHelp = class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T0_M2_WelcomeToArmory') || Movie.Pres.ScreenStack.IsInStack(class'UIAfterAction');

	super(UIArmory).InitArmory(UnitRef,,,,,, bInstantTransition);

	List = Spawn(class'UIList', self).InitList('', 58, 170, 630, 700);
	List.OnSelectionChanged = PreviewRow;
	List.bStickyHighlight = false;
	List.bAutosizeItems = false;

	/* LeadershipButton = Spawn(class'UIButton', self).InitButton(, strLeadershipButton, ViewLeadershipStats); */
	/* LeadershipButton.SetPosition(58, 971); //100,100 */
	PopulateData();

	MC.FunctionVoid("animateIn");
}


simulated function PopulateData()
{
	local XComGameState_Unit Unit;
	local GO_GameState_UnitDomainExperience UnitDomainState;
  local X2StrategyElementTemplateManager Manager;
  local array<X2StrategyElementTemplate> Templates;
  local X2StrategyElementTemplate Template;
  local GO_AbilityDomainTemplate DomainTemplate;
  local GO_UIArmory_AbilityDomainRow DomainRow;
  local int ix;


	Unit = GetUnit();
  UnitDomainState = class'GuerrillaOperativeUtilities'.static.GetOrCreateUnitDomainExperience(Unit);

	AS_SetTitle("", strScreenTitle, "", "", "");

	if (ClassRowItem == none)
	{
		ClassRowItem = Spawn(class'UIArmory_PromotionItem', self);
		ClassRowItem.MCName = 'classRow';
		ClassRowItem.InitPromotionItem(0);
	}
	ClassRowItem.Hide();

  Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
  Templates = Manager.GetAllTemplatesOfClass(class'GO_AbilityDomainTemplate');

  foreach Templates(Template, ix)
  {
    DomainTemplate = GO_AbilityDomainTemplate(Template);
    DomainRow = GO_UIArmory_AbilityDomainRow(List.GetItem(ix));
    `log("Setting up DomainRow:" @ ix);

    if (DomainRow == none)
    {
      DomainRow = GO_UIArmory_AbilityDomainRow(
        List.CreateItem(class'GO_UIArmory_AbilityDomainRow')
      ).InitDomainRow(DomainTemplate);
      DomainRow.ScreenUI = self;
    }

    DomainRow.ApplyUnitStats(
      UnitDomainState.GetStatsForDomain(DomainTemplate.DataName)
    );
  }
}

function LearnDomainAbility(
  name DomainName, eGO_AbilityLevel AbilityLevel, int AbilityIx
)
{
	local XComGameState_Unit Unit;
  local XComGameState NewGameState;
	local GO_GameState_UnitDomainExperience UnitDomainState;

	Unit = GetUnit();
  UnitDomainState = class'GuerrillaOperativeUtilities'.static.GetOrCreateUnitDomainExperience(Unit);

  NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("IniitUnitDomainExperience");
  UnitDomainState = GO_GameState_UnitDomainExperience(
    NewGameState.CreateStateObject(class'GO_GameState_UnitDomainExperience', UnitDomainState.ObjectID)
  );
  UnitDomainState.LearnAbilityForDomain(DomainName, AbilityLevel, AbilityIx);
  NewGameState.AddStateObject(UnitDomainState);
  `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
  PopulateData();
}


function PreviewDomainAbility(
  name DomainName, eGO_AbilityLevel AbilityLevel, int AbilityIx
)
{
	local XComGameState_Unit Unit;
  local X2StrategyElementTemplateManager Manager;
  local X2AbilityTemplateManager AbilityManager;
	local string TmpStr;

  local GO_AbilityDomainTemplate DomainTemplate;
  local X2AbilityTemplate AbilityTemplate;
  local GO_AbilityData AbilityData;
	// local GO_GameState_UnitDomainExperience UnitDomainState;

	Unit = GetUnit();
  // UnitDomainState = class'GuerrillaOperativeUtilities'.static.GetOrCreateUnitDomainExperience(Unit);
  Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
  DomainTemplate = GO_AbilityDomainTemplate(Manager.FindStrategyElementTemplate(DomainName));
  AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	MC.BeginFunctionOp("setAbilityPreview");

  switch (AbilityLevel) {
    case eGO_AbilityLevel_Competence:
      AbilityData = DomainTemplate.CompetenceAbilities[AbilityIx]; break;
    case eGO_AbilityLevel_Expertise:
      AbilityData = DomainTemplate.ExpertiseAbilities[AbilityIx]; break;
    case eGO_AbilityLevel_Mastery:
      AbilityData = DomainTemplate.MasteryAbilities[AbilityIx]; break;
  }
  `log("Preview Domain Ability Hopefully here:" @ AbilityData.AbilityName);

  AbilityTemplate = AbilityManager.FindAbilityTemplate(AbilityData.AbilityName);

  if(AbilityTemplate != none)
  {
    MC.QueueString(AbilityTemplate.IconImage); // icon

    TmpStr = AbilityTemplate.LocFriendlyName != "" ? AbilityTemplate.LocFriendlyName : ("Missing 'LocFriendlyName' for " $ AbilityTemplate.DataName);
    MC.QueueString(Caps(TmpStr)); // name

    TmpStr = AbilityTemplate.HasLongDescription() ? AbilityTemplate.GetMyLongDescription(, Unit) : ("Missing 'LocLongDescription' for " $ AbilityTemplate.DataName);
    MC.QueueString(TmpStr); // description
    MC.QueueBoolean(false); // isClassIcon
  }
  else
  {
    MC.QueueString(""); // icon
    MC.QueueString(""); // name
    MC.QueueString(""); // description
    MC.QueueBoolean(false); // isClassIcon
  }

  // blank left side for now
  MC.QueueString(""); // icon
  MC.QueueString(""); // name
  MC.QueueString(""); // description
  MC.QueueBoolean(false); // isClassIcon

	MC.EndOp();
}
