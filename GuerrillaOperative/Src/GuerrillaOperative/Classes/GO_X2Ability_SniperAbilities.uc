class GO_X2Ability_SniperAbilities extends X2Ability;

var localized string SetupAbilityFlyover;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateSetupAbility());

	return Templates;
}

static function X2AbilityTemplate CreateSetupAbility()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTrigger_EventListener		Listener;
	local GO_X2Effect_SniperSetup                   SetupEffect;
	local X2AbilityCost_ActionPoints        ActionPointCost;
  local X2Condition_UnitEffects ExcludeEffects;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Sniper_Setup');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_squadsight";
  Template.ShotHUDPriority = 100;

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Neutral;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);


	ExcludeEffects = new class'X2Condition_UnitEffects';
	ExcludeEffects.AddExcludeEffect('Squadsight', 'AA_GO_Sniper_InSetUp');
	Template.AbilityShooterConditions.AddItem(ExcludeEffects);

	SetupEffect = new class'GO_X2Effect_SniperSetup';
	SetupEffect.BuildPersistentEffect(1, true, , , eGameRule_PlayerTurnBegin);
	SetupEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, , , Template.AbilitySourceName);
	SetupEffect.VisualizationFn = StatModVisualizationApplied;
	SetupEffect.EffectRemovedVisualizationFn = StatModVisualizationRemoved;
	SetupEffect.AddPersistentStatChange(eStat_Defense, -20);
	Template.AddTargetEffect(SetupEffect);

  Template.ActivationSpeech = 'CombatStim';
  Template.bShowActivation = true;
  Template.bSkipFireAction = true;
  Template.CustomSelfFireAnim = 'FF_FireMedkitSelf';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.Hostility = eHostility_Neutral;

	Template.bCrossClassEligible = true;

	return Template;
}

static function StatModVisualizationApplied(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

static function StatModVisualizationRemoved(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

