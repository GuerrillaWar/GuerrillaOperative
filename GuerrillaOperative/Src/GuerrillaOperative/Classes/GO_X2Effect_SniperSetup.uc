class GO_X2Effect_SniperSetup extends X2Effect_Squadsight;

var array<StatChange>	m_aStatChanges;
var bool				bForceReapplyOnRefresh; 

simulated function AddPersistentStatChange(ECharStatType StatType, float StatAmount, optional EStatModOp InModOp=MODOP_Addition )
{
	local StatChange NewChange;
	
	NewChange.StatType = StatType;
	NewChange.StatAmount = StatAmount;
	NewChange.ModOp = InModOp;

	m_aStatChanges.AddItem(NewChange);
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit kTargetUnitState;
	local int OriginalHP, NewHP;

	NewEffectState.StatChanges = m_aStatChanges;
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);

	if (NewEffectState.StatChanges.Length == 0)
	{
		`RedScreenOnce("Effect" @ EffectName @ "has no stat modifiers. Author: jbouscher / @gameplay");
		return;
	}
	kTargetUnitState = XComGameState_Unit(kNewTargetState);

	if( kTargetUnitState != None )
	{
		OriginalHP = kTargetUnitState.GetCurrentStat(eStat_HP);
		kTargetUnitState.ApplyEffectToStats(NewEffectState, NewGameState);
		NewHP = kTargetUnitState.GetCurrentStat(eStat_HP);
		if (NewHP > OriginalHP)
		{
			if(kTargetUnitState.LowestHP == OriginalHP)
			{
				kTargetUnitState.LowestHP = NewHP;              //  a persistent HP increase is allowed to bump the lowest known HP value
			}

			if(kTargetUnitState.HighestHP == OriginalHP)
			{
				kTargetUnitState.HighestHP = NewHP;				//  a persistent HP increase is allowed to bump the highest known HP value
			}
			
		}
	}
}

//Occurs once per turn during the Unit Effects phase
simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit kOldTargetUnitState, kNewTargetUnitState;	

	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

	kOldTargetUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if( kOldTargetUnitState != None )
	{
		kNewTargetUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', kOldTargetUnitState.ObjectID));
		kNewTargetUnitState.UnApplyEffectFromStats(RemovedEffectState, NewGameState);
		NewGameState.AddStateObject(kNewTargetUnitState);
	}
}

function UnitEndedTacticalPlay(XComGameState_Effect EffectState, XComGameState_Unit UnitState)
{
	UnitState.UnApplyEffectFromStats(EffectState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	if (AbilityContext.InputContext.MovementPaths[0].MovementTiles.Length > 0)
	{
		EffectState.RemoveEffect(NewGameState, NewGameState);
	}

	return false;
}
