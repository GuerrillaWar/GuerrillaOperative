class GO_X2StrategyElement_DefaultAbilityDomains extends X2StrategyElement
  dependson(GO_AbilityDomainTemplate)
  config(ClassData);

var config array<name> AbilityDomains;

static function array<X2DataTemplate> CreateTemplates ()
{
	local array<X2DataTemplate> Templates;
	local GO_AbilityDomainTemplate Template;
	local name AbilityDomainName;
	
	foreach default.AbilityDomains(AbilityDomainName)
	{
		`CREATE_X2TEMPLATE(class'GO_AbilityDomainTemplate', Template, AbilityDomainName);
		Templates.AddItem(Template);
	}

	return Templates;
}
