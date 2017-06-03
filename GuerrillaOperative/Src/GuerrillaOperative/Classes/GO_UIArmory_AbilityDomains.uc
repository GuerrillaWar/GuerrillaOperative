class GO_UIArmory_AbilityDomains extends UIArmory_Promotion;



var localized string strScreenTitle;

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
	local int i, MaxRank;
	local string AbilityIcon1, AbilityIcon2, AbilityName1, AbilityName2, HeaderString;
	local bool bHasAbility1, bHasAbility2;
	local XComGameState_Unit Unit;
	local X2AbilityTemplate AbilityTemplate1, AbilityTemplate2;
	local X2AbilityTemplateManager AbilityTemplateManager;
  local X2StrategyElementTemplateManager Manager;
  local array<X2StrategyElementTemplate> Templates;
  local X2StrategyElementTemplate Template;
  local GO_AbilityDomainTemplate DomainTemplate;
  local GO_UIArmory_AbilityDomainRow DomainRow;
  local int ix;


	Unit = GetUnit();
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();


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
    }
  }
}
