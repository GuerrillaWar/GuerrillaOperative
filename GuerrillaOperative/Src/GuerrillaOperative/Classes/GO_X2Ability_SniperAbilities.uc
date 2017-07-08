class GO_X2Ability_SniperAbilities extends X2Ability config(GO_Abilities);

var localized string SetupAbilityFlyover;
var localized string ZeroSightsFlyover;
var localized string ZeroSightsEffectName;
var localized string ZeroSightsEffectDesc;

var config int RECON_BY_SCOPE_DURATION;
var config float RECON_BY_SCOPE_RADIUS;

var config int SETUP_DEFENSE_MODIFIER;

var config int VITAL_POINT_AIM_MODIFIER;
var config int VITAL_POINT_CRIT_MODIFIER;

var config int LOCKDOWN_AIM_MODIFIER;
var config int LOCKDOWN_CRIT_MODIFIER;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateSetupAbility());

  // COMPETENCY
	Templates.AddItem(CreateZeroSightsAbility());
	Templates.AddItem(CreateReconByScopeAbility());
	Templates.AddItem(CreateVitalPointTargetingAbility());

  // EXPERTISE
	Templates.AddItem(CreateDisplacementAbility());
	Templates.AddItem(CreateDisplacementTriggerAbility());
	Templates.AddItem(CreateInTheOpenAbility());

  // MASTERY
	Templates.AddItem(CreateLockdownAbility());
	Templates.AddItem(CreateLockdownShotAbility());

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
	Template.IconImage = "img:///XPerkIconPack.UIPerk_rifle_shot";
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


static function X2AbilityTemplate CreateVitalPointTargetingAbility()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCooldown                 Cooldown;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
  local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Sniper_VitalPointTargeting');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_deadeye";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = default.VITAL_POINT_AIM_MODIFIER;
	ToHitCalc.BuiltInCritMod = default.VITAL_POINT_CRIT_MODIFIER;
	Template.AbilityToHitCalc = ToHitCalc;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 2;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
  Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

  KnockbackEffect = new class'X2Effect_Knockback';
  KnockbackEffect.KnockbackDistance = 2;
  KnockbackEffect.bUseTargetLocation = true;
  Template.AddTargetEffect(KnockbackEffect);

	Template.bAllowFreeFireWeaponUpgrade = true;
	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = true;

	return Template;
}


static function X2AbilityTemplate CreateInTheOpenAbility()
{
	local X2AbilityTemplate                 Template;	
	local GO_X2Effect_InTheOpen		InTheOpenEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Sniper_InTheOpen');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_inthezone";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	Template.bIsPassive = true;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	InTheOpenEffect = new class'GO_X2Effect_InTheOpen';
	InTheOpenEffect.BuildPersistentEffect(1, true, false, false);
	InTheOpenEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(InTheOpenEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

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

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Sniper_DisplacementTrigger');

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


static function X2AbilityTemplate CreateLockdownAbility()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
  local X2Effect_Persistent               LockdownEffect;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2Effect_ReserveActionPoints  ReservePointsEffect;
	local X2AbilityCost_ActionPoints        ActionPointCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Sniper_Lockdown');

	Template.IconImage = "img:///XPerkIconPack.UIPerk_move_blossom";
  Template.AdditionalAbilities.AddItem('GO_Sniper_LockdownShot');
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	AmmoCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(AmmoCost);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 2;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	ReservePointsEffect = new class'X2Effect_ReserveActionPoints';
	ReservePointsEffect.ReserveType = 'GO_Lockdown';
	Template.AddShooterEffect(ReservePointsEffect);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	LockdownEffect = new class'X2Effect_Persistent';
	LockdownEffect.EffectName = 'GO_LockdownTarget';
	LockdownEffect.BuildPersistentEffect(2, false, false, false, eGameRule_PlayerTurnBegin);
	LockdownEffect.SetSourceDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, Template.AbilitySourceName);
	LockdownEffect.SetupEffectOnShotContextResult(true, true);
	Template.AddTargetEffect(LockdownEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

  Template.bShowActivation = true;
  Template.bSkipFireAction = true;

	Template.bCrossClassEligible = true;

	return Template;
}



static function X2AbilityTemplate CreateLockdownShotAbility()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
  local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;
  local X2AbilityTrigger_Event            Trigger;
  local X2Condition_AbilityProperty       AbilityCondition;
  local X2Condition_UnitEffectsWithAbilitySource LockdownCondition;
  local X2Effect_RemoveEffects            LockdownRemoval;
  local X2AbilityTarget_Single            SingleTarget;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Sniper_LockdownShot');

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = default.LOCKDOWN_AIM_MODIFIER;
	ToHitCalc.BuiltInCritMod = default.LOCKDOWN_CRIT_MODIFIER;
  ToHitCalc.bReactionFire = false; // no reaction penalty, sniper is prepared
	Template.AbilityToHitCalc = ToHitCalc;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.bFreeCost = true;
	ReserveActionPointCost.AllowedTypes.AddItem('GO_Lockdown');
	Template.AbilityCosts.AddItem(ReserveActionPointCost);

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	LockdownCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	LockdownCondition.AddRequireEffect('GO_LockdownTarget', 'AA_UnitIsTargeted');
	Template.AbilityTargetConditions.AddItem(LockdownCondition);

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
  Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

  LockdownRemoval = new class'X2Effect_RemoveEffects';
  LockdownRemoval.EffectNamesToRemove.AddItem('GO_LockdownTarget');
  Template.AddTargetEffect(LockdownRemoval);

  KnockbackEffect = new class'X2Effect_Knockback';
  KnockbackEffect.KnockbackDistance = 2;
  KnockbackEffect.bUseTargetLocation = true;
  Template.AddTargetEffect(KnockbackEffect);

	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_AttackObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.bAllowFreeFireWeaponUpgrade = true;
	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

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

