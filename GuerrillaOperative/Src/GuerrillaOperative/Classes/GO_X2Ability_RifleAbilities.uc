class GO_X2Ability_RifleAbilities extends X2Ability config(GO_Abilities);

/* var localized string SetupAbilityFlyover; */
/* var localized string ZeroSightsFlyover; */
/* var localized string ZeroSightsEffectName; */
/* var localized string ZeroSightsEffectDesc; */

/* var config int RECON_BY_SCOPE_DURATION; */
/* var config float RECON_BY_SCOPE_RADIUS; */

/* var config int SETUP_DEFENSE_MODIFIER; */

/* var config int VITAL_POINT_AIM_MODIFIER; */
/* var config int VITAL_POINT_CRIT_MODIFIER; */

/* var config int LOCKDOWN_AIM_MODIFIER; */
/* var config int LOCKDOWN_CRIT_MODIFIER; */

var config int SentinelProcChance;
var config name DefensivePostureShotAbility;
var config name EverVigilantOverwatchAbility;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

  // COMPETENCY
  Templates.AddItem(CreateConcentratedFireAbility());
  Templates.AddItem(CreateDefensivePostureAbility());
  Templates.AddItem(CreateFireAndMoveAbility());
  // DeathFromAbove vanilla

  // EXPERTISE
  Templates.AddItem(CreateSentinelAbility());
  // CoveringFire vanilla

  // MASTERY
  Templates.AddItem(CreateEverVigilantAbility());
  Templates.AddItem(CreateEverVigilantTriggerAbility());

	return Templates;
}


static function X2AbilityTemplate CreateConcentratedFireAbility()
{
	local X2AbilityTemplate						Template;
	local GO_X2Effect_ConcentratedFire               FireEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Rifle_ConcentratedFire');
	Template.IconImage = "img:///XPerkIconPack.UIPerk_rifle_chevron_x2";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bCrossClassEligible = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	FireEffect = new class'GO_X2Effect_ConcentratedFire';
	FireEffect.BuildPersistentEffect(1, true, false, false);
	FireEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(FireEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}


static function X2AbilityTemplate CreateDefensivePostureAbility()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_ReserveActionPoints      ReserveActionPointsEffect;
	local array<name>                       SkipExclusions;
	local GO_X2Effect_DefensivePosture      CoveringFireEffect;
	local X2Condition_UnitEffects           SuppressedCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Rifle_DefensivePosture');
	
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	AmmoCost.bFreeCost = true;                  //  ammo is consumed by the shot, not by this, but this should verify ammo is available
	Template.AbilityCosts.AddItem(AmmoCost);
	
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.bConsumeAllPoints = true;   //  this will guarantee the unit has at least 1 action point
	ActionPointCost.bFreeCost = true;           //  ReserveActionPoints effect will take all action points away
	ActionPointCost.DoNotConsumeAllEffects.Length = 0;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.Length = 0;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);
	
	ReserveActionPointsEffect = new class'X2Effect_ReserveOverwatchPoints';
	Template.AddTargetEffect(ReserveActionPointsEffect);

	CoveringFireEffect = new class'GO_X2Effect_DefensivePosture';
	CoveringFireEffect.AbilityToActivate = default.DefensivePostureShotAbility;
  CoveringFireEffect.bDirectAttackOnly = true;
  CoveringFireEffect.bPreEmptiveFire = false;
  CoveringFireEffect.bOnlyDuringEnemyTurn = true;
  CoveringFireEffect.MaxPointsPerTurn = 10;
  CoveringFireEffect.GrantActionPoint = 'returnfire';
	CoveringFireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	Template.AddTargetEffect(CoveringFireEffect);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideIfOtherAvailable;
	Template.IconImage = "img:///XPerkIconPack.UIPerk_rifle_defense";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.OVERWATCH_PRIORITY;
	Template.bNoConfirmationWithHotKey = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.AbilityConfirmSound = "Unreal2DSounds_OverWatch";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Overwatch";
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;

	Template.Hostility = eHostility_Defensive;

	return Template;	
}


static function X2AbilityTemplate CreateFireAndMoveAbility()
{
	local X2AbilityTemplate						Template;
	local GO_X2Effect_FireAndMove               FireEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Rifle_FireAndMove');
	Template.IconImage = "img:///XPerkIconPack.UIPerk_rifle_move2";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bCrossClassEligible = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	FireEffect = new class'GO_X2Effect_FireAndMove';
	FireEffect.BuildPersistentEffect(1, true, false, false);
	FireEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(FireEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}



static function X2AbilityTemplate CreateSentinelAbility()
{
	local X2AbilityTemplate             Template;
	local X2Effect_Guardian             PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Rifle_Sentinel');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sentinel";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	PersistentEffect = new class'X2Effect_Guardian';
	PersistentEffect.BuildPersistentEffect(1, true, false);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,, Template.AbilitySourceName);
	PersistentEffect.ProcChance = default.SentinelProcChance;
  PersistentEffect.AllowedAbilities.AddItem('SUT_OverwatchSnapShot');
	Template.AddTargetEffect(PersistentEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}



static function X2AbilityTemplate CreateEverVigilantAbility()
{
	local X2AbilityTemplate						Template;

	Template = PurePassive(
    'GO_Rifle_EverVigilant',
    "img:///UILibrary_PerkIcons.UIPerk_evervigilant"
  );
  Template.AdditionalAbilities.AddItem('GO_Rifle_EverVigilantTrigger');
	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate CreateEverVigilantTriggerAbility()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTrigger_EventListener		Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Rifle_EverVigilantTrigger');

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'PlayerTurnEnded';
	Trigger.ListenerData.Filter = eFilter_Player;
	Trigger.ListenerData.EventFn = static.EverVigilantTurnEndListener;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.bCrossClassEligible = true;

	return Template;
}

static function EventListenerReturn EverVigilantTurnEndListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Unit UnitState;
	local UnitValue AttacksThisTurn, NonMoveActionsThisTurn;
	local bool GotAttackValue, GotNonMoveValue;
	local StateObjectReference OverwatchRef;
	local XComGameState_Ability OverwatchState;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
  foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
  {
    if (
      UnitState != none &&
      !UnitState.IsHunkeredDown() &&
      UnitState.FindAbility('GO_Rifle_EverVigilant').ObjectID > 0
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
        OverwatchRef = UnitState.FindAbility(default.EverVigilantOverwatchAbility);
        OverwatchState = XComGameState_Ability(History.GetGameStateForObjectID(OverwatchRef.ObjectID));
        if (OverwatchState != none && OverwatchState.CanActivateAbility(UnitState,,true) == 'AA_Success')
        {
          NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
          UnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					UnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);					
          NewGameState.AddStateObject(UnitState);
          `TACTICALRULES.SubmitGameState(NewGameState);
          OverwatchState.AbilityTriggerEventListener_Self(EventData, EventSource, GameState, EventID);
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

