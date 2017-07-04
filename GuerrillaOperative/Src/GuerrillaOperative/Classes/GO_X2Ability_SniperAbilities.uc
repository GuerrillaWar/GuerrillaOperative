class GO_X2Ability_SniperAbilities extends X2Ability config(GO_Abilities);

var localized string SetupAbilityFlyover;
var localized string ZeroSightsFlyover;
var localized string ZeroSightsEffectName;
var localized string ZeroSightsEffectDesc;

var config int RECON_BY_SCOPE_DURATION;
var config float RECON_BY_SCOPE_RADIUS;

var config int SETUP_DEFENSE_MODIFIER;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateSetupAbility());

  // COMPETENCY
	Templates.AddItem(CreateZeroSightsAbility());
	Templates.AddItem(CreateReconByScopeAbility());

  // EXPERTISE
	Templates.AddItem(CreateDisplacementAbility());
	Templates.AddItem(CreateDisplacementTriggerAbility());

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
	Template.IconImage = "img:///XPerkIconPack.UIPerk_rifle_sniper";
  Template.ShotHUDPriority = 100;

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Neutral;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.DeepCoverActionPoint);
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
	SetupEffect.AddPersistentStatChange(eStat_Defense, default.SETUP_DEFENSE_MODIFIER);
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

static function X2AbilityTemplate CreateZeroSightsAbility()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTrigger_EventListener		Listener;
  local X2AbilityTarget_Cursor            Cursor;
	local GO_X2Effect_ZeroSights            ZeroEffect;
	local X2AbilityCost_ActionPoints        ActionPointCost;
  local X2Condition_UnitEffects IncludeEffects;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Sniper_ZeroSights');
	Template.IconImage = "img:///XPerkIconPack.UIPerk_shield_shot";
  Template.ShotHUDPriority = 100;

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityConfirmSound = "TacticalUI_Activate_Ability_Run_N_Gun";

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;

  Cursor = new class'X2AbilityTarget_Cursor';
  Cursor.bRestrictToSquadsightRange = true;

	Template.AbilityTargetStyle = Cursor;
	Template.TargetingMethod = class'X2TargetingMethod_Teleport';

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);


	IncludeEffects = new class'X2Condition_UnitEffects';
	IncludeEffects.AddRequireEffect('Squadsight', 'AA_GO_Sniper_NeedSetup');
	Template.AbilityShooterConditions.AddItem(IncludeEffects);

	ZeroEffect = new class'GO_X2Effect_ZeroSights';
	ZeroEffect.BuildPersistentEffect(1, true, , , eGameRule_PlayerTurnBegin);
	ZeroEffect.SetDisplayInfo(ePerkBuff_Bonus, default.ZeroSightsEffectName, default.ZeroSightsEffectDesc, Template.IconImage, , , Template.AbilitySourceName);
	ZeroEffect.VisualizationFn = StatModVisualizationApplied;
	ZeroEffect.EffectRemovedVisualizationFn = StatModVisualizationRemoved;
	Template.AddShooterEffect(ZeroEffect);

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


static function X2AbilityTemplate CreateReconByScopeAbility()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTrigger_EventListener		Listener;
  local X2AbilityTarget_Cursor            Cursor;
  local X2Effect_PersistentSquadViewer    ViewerEffect;
	local X2AbilityCost_ActionPoints        ActionPointCost;
  local X2Condition_UnitEffects IncludeEffects;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Sniper_ReconByScope');
	Template.IconImage = "img:///XPerkIconPack.UIPerk_sniper_circle";
  Template.ShotHUDPriority = 100;

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityConfirmSound = "TacticalUI_Activate_Ability_Run_N_Gun";

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;

  Cursor = new class'X2AbilityTarget_Cursor';
  Cursor.bRestrictToSquadsightRange = true;

	Template.AbilityTargetStyle = Cursor;
	Template.TargetingMethod = class'X2TargetingMethod_Teleport';

  Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
  Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);


	IncludeEffects = new class'X2Condition_UnitEffects';
	IncludeEffects.AddRequireEffect('Squadsight', 'AA_GO_Sniper_NeedSetup');
	Template.AbilityShooterConditions.AddItem(IncludeEffects);

	ViewerEffect = new class'X2Effect_PersistentSquadViewer';
	ViewerEffect.BuildPersistentEffect(default.RECON_BY_SCOPE_DURATION, false, false, false, eGameRule_PlayerTurnBegin);
  ViewerEffect.ViewRadius = default.RECON_BY_SCOPE_RADIUS;
  ViewerEffect.bUseWeaponRadius = false;
	Template.AddShooterEffect(ViewerEffect);

  Template.ActivationSpeech = 'CombatStim';
  Template.bShowActivation = true;
  Template.bSkipFireAction = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.Hostility = eHostility_Neutral;

	Template.bCrossClassEligible = true;

	return Template;
}



static function X2AbilityTemplate CreateDisplacementAbility()
{
	local X2AbilityTemplate						Template;

	Template = PurePassive(
    'GO_Sniper_Displacement',
    "img:///XPerkIconPack.UIPerk_move_sniper"
  );
  Template.AdditionalAbilities.AddItem('GO_Sniper_DisplacementTrigger');
	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate CreateDisplacementTriggerAbility()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTrigger_EventListener		Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Sniper_Setup');

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'PlayerTurnEnded';
	Trigger.ListenerData.Filter = eFilter_Player;
	Trigger.ListenerData.EventFn = static.DisplacementTurnEndListener;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.bCrossClassEligible = true;

	return Template;
}

function EventListenerReturn DisplacementTurnEndListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Unit UnitState;
	local UnitValue AttacksThisTurn, NonMoveActionsThisTurn;
	local bool GotAttackValue, GotNonMoveValue;
	local StateObjectReference SetupRef;
	local XComGameState_Ability SetupState;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
  foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
  {
    if (
      UnitState != none &&
      !UnitState.IsHunkeredDown() &&
      UnitState.FindAbility('GO_Sniper_Displacement').ObjectID > 0
    )
    {
      GotAttackValue = UnitState.GetUnitValue('AttacksThisTurn', AttacksThisTurn);
      GotNonMoveValue = UnitState.GetUnitValue('NonMoveActionsThisTurn', NonMoveActionsThisTurn);
      if (
        (!GotAttackValue || AttacksThisTurn.fValue == 0) && // didn't attack
        (!GotNonMoveValue || NonMoveActionsThisTurn.fValue == 0) && // didn't use non move abilities
        (UnitState.NumActionPoints() == 0) // used all ability points
      )
      {
        SetupRef = UnitState.FindAbility('GO_Sniper_Setup');
        SetupState = XComGameState_Ability(History.GetGameStateForObjectID(SetupRef.ObjectID));
        if (SetupState != none && SetupState.CanActivateAbility(UnitState,,true) == 'AA_Success')
        {
          NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
          UnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
          //  give the unit an action point so they can activate set up
          UnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.DeepCoverActionPoint);					
          NewGameState.AddStateObject(UnitState);
          `TACTICALRULES.SubmitGameState(NewGameState);
          SetupState.AbilityTriggerEventListener_Self(EventData, EventSource, GameState, EventID);
        }
      }
    }
  }

	return ELR_NoInterrupt;
}


static function StatModVisualizationApplied(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

static function StatModVisualizationRemoved(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

