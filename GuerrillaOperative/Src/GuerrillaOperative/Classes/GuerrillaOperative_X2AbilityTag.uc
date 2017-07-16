class GuerrillaOperative_X2AbilityTag extends X2AbilityTag;


var X2AbilityTag WrappedTag;


// From X2AbilityTag. Expands a tag. The specific tags we handle depend on the ability the tag
// applies to. We look inside the ability template and check each effect to see if we know how
// to get the tag value from that effect - usually this is because the effect implements
// XMBEffectInterface and we call GetTagValue on it. We also have special handling for
// X2Effect_PersistentStatChange.
event ExpandHandler(string InString, out string OutString)
{
  local name Type;
  local XComGameState_Ability AbilityState;
  local XComGameState_Effect EffectState;
  /* local XComGameState_Item ItemState; */
  /* local X2ItemTemplate ItemTemplate; */
  local X2AbilityTemplate AbilityTemplate;
  /* local X2AbilityToHitCalc_StandardAim ToHitCalc; */
  /* local X2Effect EffectTemplate; */
  local XComGameStateHistory History;
  local array<string> Split;
  /* local int idx; */
  local bool plusFlag;

  local GO_X2Effect_ZeroSights ZeroSightsEffect;

  History = `XCOMHISTORY;

  OutString = "";

  Split = SplitString(InString, ":");

  if (left(Split[0], 1) == "+")
  {
    plusFlag = true;
    Type = name(mid(Split[0], 1));
  }
  else
  {
    Type = name(Split[0]);
  }

  // Depending on where this tag is being expanded, ParseObj may be an XComGameState_Effect, an
  // XComGameState_Ability, or an X2AbilityTemplate.
  EffectState = XComGameState_Effect(ParseObj);
  AbilityState = XComGameState_Ability(ParseObj);
  AbilityTemplate = X2AbilityTemplate(ParseObj);
    
  // If we have an XComGameState_Effect or XComGameState_Ability, find the ability template from it.
  if (EffectState != none)
  {
    AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
  }
  if (AbilityState != none)
  {
    AbilityTemplate = AbilityState.GetMyTemplate();
  }

  // We allow tags of the form "<Ability:[tag]:[name]/>", which causes us to look for the tag's 
  // value in the ability with template name [name] instead of the template with the tag itself.
  // This is useful for abilities where the actual effect is in a secondary ability.
  if (Split.Length == 2)
  {
    AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(name(Split[1]));
  }
  else if (AbilityTemplate != none && Right(AbilityTemplate.DataName, 5) ~= "_Icon")
  {
    // If the template name ends with "_Icon", it was added by AddIconPassive(). Use the
    // primary ability template instead.
    AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(name(Left(AbilityTemplate.DataName, Len(AbilityTemplate.DataName) - 5)));
  }

  if (OutString != "")
  {
    if (plusFlag && left(OutString, 1) != "-")
      OutString = "+" $ OutString;
    return;
  }

  switch (Type)
  {
    // <Ability:AssociatedWeapon/> returns the actual name of the associated weapon or item
    // for an ability. For example, if it is associated with a Gauss Rifle, it will return
    // "Gauss Rifle".
    case 'ZeroSightsRange':
      if (EffectState != none)
      {
        ZeroSightsEffect = GO_X2Effect_ZeroSights(
          EffectState.GetX2Effect()
        );
        OutString = String(ZeroSightsEffect.GetZeroDistanceFromEffectState(EffectState));
      }
      else
      {
        OutString = "ZeroSightsRangeNotFound";
      }
      break;

    /* // <Ability:ToHit/> can be an actual to-hit bonus granted by the ability (handled earlier), */
    /* // a negative defense modifier granted by the ability, or the inherent to-hit modifier of */
    /* // the ability itself. */
    /* case 'ToHit': */
    /*   if (FindStatBonus(AbilityTemplate, eStat_Defense, OutString, -1)) */
    /*   { */
    /*     break; */
    /*   } */
    /*   // Fallthrough */
    /* // <Ability:BaseToHit/> returns the inherent to-hit modifier of the ability itself. */
    /* case 'BaseToHit': */
    /*   ToHitCalc = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc); */
    /*   if (ToHitCalc != none) */
    /*   { */
    /*     OutString = string(ToHitCalc.BuiltInHitMod); */
    /*   } */
    /*   break; */

    /* // <Ability:Crit/> can be a crit bonus granted by the ability (handled earlier), or the */
    /* // inherent crit modifier of the ability itself. */
    /* case 'Crit': */
    /* // <Ability:BaseCrit/> returns the inherent crit modifier of the ability itself. */
    /* case 'BaseCrit': */
    /*   ToHitCalc = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc); */
    /*   if (ToHitCalc != none) */
    /*   { */
    /*     OutString = string(ToHitCalc.BuiltInCritMod); */
    /*   } */
    /*   break; */

    // We don't handle this tag, check the wrapped tag.
    default:
      WrappedTag.ParseObj = ParseObj;
      WrappedTag.StrategyParseObj = StrategyParseObj;
      WrappedTag.GameState = GameState;
      WrappedTag.ExpandHandler(InString, OutString);
      return;
  }

  if (OutString != "")
  {
    if (plusFlag && left(OutString, 1) != "-")
      OutString = "+" $ OutString;
    return;
  }

  OutString = "<Ability:"$InString$"/>";
}
