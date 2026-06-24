# MSEM Sets

Sets part of [MSEM](https://snapdragonfirework.wixsite.com/msem2).

Sets information can be found on [lackeybot](https://lackeybot.com/msem/search).

## Changes

These changes might not be reflected in their official ruling.

* All Hounds are now Dogs. This also apply to abilities that target and/or applies to Hounds.
  * Haggard Jackal is now a Zombie Jackal instead of a Zombie Hound.
* Some cards have their wording changed to better reflect real MTG cards.

## How to install?

### Manually

* Drop the `custom` folder in `%appdata%\Forge`;
* Drop the `pics` folder in `%localappdata%\Forge\cache`;

### Scripts (Powershell)

* Run the `install.ps1` script;

## Set implementation progress

```text
Video Horror System (VHS)             -  97% (83/86)
  Missing cards:
    * Maddened Preacher
    * Snowfield Doppelganger
    * Wiretapper
Nangjiao In Bloom (NJB)               -  35% (106/297)
  Missing cards:
    * Diao of the Opal Infantry
Riddles of Revio (RVO)                -  83% (226/272)
  Missing cards:
    * Every card that references the supertype Riddle.
    * Every card that references modal spells. (Cryptic, etc.)
    * Every card that references "reselect modes".
    * Every card that has Align X.
    * Ancient Tome
    * Dthan, Who Bloodies the Sands
    * Reytha's Discovery
Worlds Away (WAY)                     -   3% (11/262)
Storytime (101)                       -  14% (15/101)
Kaleidoscope (KLC)                    -  100%
Path of Shadows (PSA)                 -  89% (187/209)
  Missing cards:
     * Every card with Inscribe, or referencing it.
     * The Sacred Gate
A Tourney at Whiterun (TWR)           -  100%
Tides of War (TOW)                    -  36% (98/271)
Pyramids of Atuum (POA)               -  98% (126/128)
  Missing cards:
    * Righteous Priestess
    * Sphinx of Riddles

Reprints / Promo sets:
MSEM Champions (CHAMPIONS)
MSEM Champions: Masterpiece (MPS_MSE)
MSEM Secret Lair Drops (LAIR)
The Land Bundle (L)
From the Vault: Wayfarer's Shrine (SHRINE)
```

## Keywords and mechanisms implementation

Examples on how to implement custom keywords and mechanisms.

* [Aetherize](#aetherize)
* [Ascend](#ascend)
* [Art of War](#art-of-war)
* [Bleed](#bleed)
* [Deception](#deception)
* [Fabled](#fabled)
* [Fleeting](#fleeting)
* [Foresight](#foresight)
* [Golden Age](#golden-age)
* [Horrific](#horrific)
* [Infiltrate](#infiltrate)
* [Kindle](#kindle)
* [Menagerie](#menagerie)
* [Mirage](#mirage)
* [Motivate](#motivate)
* [Paranoia](#paranoia)
* [Rerun](#rerun)
* [Showcase](#showcase)
* [Torment](#torment)

### Aetherize

Aetherize is defined as:

```text
To aetherize, create a token that's a copy of it, then exile that token.
```

Implementation:

```text
A:AB$ CopyPermanent | Cost$ 3 U Sac<1/CARDNAME/this creature> | ValidTgts$ Creature.YouCtrl | TgtPrompt$ Select target creature you control | RememberTokens$ True | SpellDescription$ Aetherize target creature you control. (To aetherize, create a token that's a copy of it, then exile that token.) | SubAbility$ DBExileToken
SVar:DBExileToken:DB$ ChangeZone | Defined$ Remembered | Origin$ Battlefield | Destination$ Exile | SubAbility$ DBCleanup
SVar:DBCleanup:DB$ Cleanup | ClearRemembered$ True
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Ascend

Ascend is defined as:

```text
Ascend {2}{G} ({2}{G}: Exile this creature, then return it to the battlefield transformed. Ascend only as a sorcery.)
```

Implementation:

```text
A:AB$ ChangeZone | Named$ Ascend | Cost$ 2 G | Origin$ Battlefield | Destination$ Exile | SorcerySpeed$ True | SubAbility$ AscendTransform | RememberChanged$ True | PrecostDesc Ascend— | SpellDescription$ ({2}{G}: Exile this creature, then return it to the battlefield transformed. Ascend only as a sorcery.)
SVar:AscendTransform:DB$ ChangeZone | Defined$ Remembered | Origin$ All | Destination$ Battlefield | Transformed$ True | GainControl$ True
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Art of War

Art of War is defined as:

```text
Art of war — At the beginning of your end step, if this creature dealt damage to an opponent this turn, [...].
```

Implementation:

```text
T:Mode$ Phase | Phase$ End of Turn | ValidPlayer$ You | TriggerZones$ Battlefield | IsPresent$ Card.Self+dealtDamageToOppThisTurn | Execute$ TrigToken | TriggerDescription$ Art of war — At the beginning of your end step, if this creature dealt damage to an opponent this turn, create a 1/1 colorless Samurai creature token.
SVar:TrigToken:DB$ Token | TokenScript$ c_1_1_samurai
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Bleed

Bleed is defined as:

```text
Bleed {1}{U} (You may cast this spell for its bleed cost if an opponent lost life this turn.)
```

Implementation:

```text
S:Mode$ AlternativeCost | ValidSA$ Spell.Self | EffectZone$ All | Cost$ 2 R | CheckSVar$ X | SVarCompare$ GE1 | Description$ Bleed {2}{R} (You may cast this spell for its bleed cost if an opponent has lost life this turn.)
SVar:X:Count$LifeOppsLostThisTurn
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Deception

> It's the equivalent to Ninjutsu.

Deception is defined as:

```text
Deception {2}{U} ({2}{U}, Return an unblocked attacker you control to hand: Put this card onto the battlefield from your hand tapped and attacking.)
```

Implementation:

```text
A:AB$ ChangeZone | Cost$ 2 U Return<1/Creature.attacking+unblocked/unblocked attacker> | PrecostDesc$ Deception | CostDesc$ 2 U | ActivationZone$ Hand | Origin$ Hand | Destination$ Battlefield | Defined$ Self | Tapped$ True | Attacking$ True | SpellDescription$ ({2}{U}, Return an unblocked attacker you control to hand: Put this card onto the battlefield from your hand tapped and attacking.)
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Fabled

Fabled is defined as:

```text
Fabled {4}{G} (If you cast this for its fabled cost, put it onto the battlefield transformed attached to that creature.)
```

Used on Instant and Sorceries that target an object and then transform into an enchantment (or equipment) attached to the targetted object.

Implementation:

```text
S:Mode$ AlternativeCost | ValidSA$ Spell.Self | EffectZone$ All | Cost$ 2 W | Description$ Fabled {2}{W} (Then if you cast this for its fabled cost, put it onto the battlefield transformed attached to that creature.)

SVar:DBTransform:DB$ ChangeZone | Defined$ Self | Origin$ Stack | Destination$ Battlefield | Transformed$ True | AttachedTo$ Targeted | ConditionCheckSVar$ AltCostPaid | ConditionSVarCompare$ GE1 | SpellDescription$ If CARDNAME's fabled cost was paid, put it onto the battlefield transformed attached to that creature.
SVar:AltCostPaid:Count$AltCost.1.0
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Fleeting

Fleeting is defined as:

```text
Fleeting {U} (You may cast this spell for its fleeting cost. If you do, sacrifice it at the beginning of the next end step.)
```

Implementation:

```text
S:Mode$ Continuous | Affected$ Card.Self | MayPlay$ True | MayPlayAltManaCost$ U | AffectedZone$ Hand | EffectZone$ Hand | Description$ Fleeting {U} (You may cast this spell for its fleeting cost. If you do, sacrifice it at the beginning of the next end step.)
T:Mode$ SpellCast | ValidCard$ Card.Self | ValidSA$ Spell.MayPlaySource | Static$ True | Execute$  FleetingEndStep
SVar:FleetingEndStep:DB$ DelayedTrigger | Mode$ Phase | Phase$ End of Turn | RememberObjects$ Self | TriggerDescription$ At the beginning of the next end step, sacrifice it. | Execute$ TrigSacrifice
SVar:TrigSacrifice:DB$ SacrificeAll | Defined$ DelayTriggerRememberedLKI
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Foresight

Foresight is defined as:

```text
Foresight — Whenever you draw your second card each turn, [something]
```

Implementation:

```text
T:Mode$ Drawn | ValidCard$ Card.YouCtrl | Number$ 2 | TriggerZones$ Battlefield | Execute$ SomeTrigger | TriggerDescription$ Foresight —
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Golden Age

Golden Age is defined as:

```text
Golden age (If you cast an instant or sorcery spell, activated a nonmana ability, and attacked this turn, enter a renaissance for this game.)
```

To trigger Golden Age:

```text
#-------------------
# Golden Age trigger
#-------------------
T:Mode$ ChangesZone | Origin$ Any | Destination$ Battlefield | ValidCard$ Card.Self | CheckSVar$ GoldenCheckFinal | SVarCompare$ EQ3 | Execute$ EnterGoldenAge | TriggerDescription$ Golden age (If you cast an instant or sorcery spell, activated a nonmana ability, and attacked this turn, enter a renaissance for this game.)
T:Mode$ SpellCast | ValidCard$ Instant,Sorcery | ValidActivatingPlayer$ You | TriggerZones$ Battlefield | CheckSVar$ GoldenCheckFinal | SVarCompare$ EQ3 | Secondary$ True | Execute$ EnterGoldenAge | TriggerDescription$ Golden age (If you cast an instant or sorcery spell, activated a nonmana ability, and attacked this turn, enter a renaissance for this game.)
T:Mode$ AttackersDeclared | AttackingPlayer$ You | TriggerZones$ Battlefield | CheckSVar$ GoldenCheckFinal | SVarCompare$ EQ3 | Secondary$ True | Execute$ EnterGoldenAge | TriggerDescription$ Golden age (If you cast an instant or sorcery spell, activated a nonmana ability, and attacked this turn, enter a renaissance for this game.)
T:Mode$ AbilityCast | ValidActivatingPlayer$ You | ValidSA$ SpellAbility.!ManaAbility | TriggerZones$ Battlefield | CheckSVar$ GoldenCheckFinal | SVarCompare$ EQ3 | Secondary$ True | Execute$ EnterGoldenAge | TriggerDescription$ Golden age (If you cast an instant or sorcery spell, activated a nonmana ability, and attacked this turn, enter a renaissance for this game.)

SVar:EnterGoldenAge:DB$ Effect | Name$ Golden Age | StaticAbilities$ GoldenAgeDesc | Duration$ Permanent | Unique$ True
SVar:GoldenAgeDesc:Mode$ Continuous | Description$ You are in a renaissance.

SVar:GoldenAgeSpell:Count$ThisTurnCast_Card.Instant+YouCtrl,Card.Sorcery+YouCtrl/LimitMax.1
SVar:GoldenAgeAbility:Count$ThisTurnActivated_Activated.!ManaAbility+YouCtrl/LimitMax.1
SVar:GoldenAgeAttack:Count$AttackersDeclared/LimitMax.1
SVar:GoldenCheck1:SVar$GoldenAgeSpell/Plus.GoldenAgeAbility
SVar:GoldenCheckFinal:SVar$GoldenCheck1/Plus.GoldenAgeAttack
#-------------------
```

To check if you're in a renaissance, you can check this var if it is equal to 1:

```text
SVar:IsRenaissance:Count$ValidCommand Effect.YouCtrl+namedGolden Age/LimitMax.1
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Horrific

Horrific is defined as:

```text
You're horrific as long as you've sacrificed a permanent or discarded a card this turn.
```

To check if you're horrific, you can check this var if it is greater than 0:

```text
SVar:Horrific:PlayerCountPropertyYou$SacrificedThisTurn Permanent/Plus.PlayerCountPropertyYou$CardsDiscardedThisTurn
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Infiltrate

Infiltrate is defined as:

```text
Whenever one or more attacking creatures you control aren't blocked, this creature gets +1/+1 until end of turn.
```

Implementation:

```text
T:Mode$ AttackerUnblockedOnce | ValidAttackingPlayer$ You | Execute$ TrigPump | TriggerZones$ Battlefield | TriggerDescription$ Infiltrate (Whenever one or more attacking creatures you control aren't blocked, this creature gets +1/+1 until end of turn.)
SVar:TrigPump:DB$ Pump | Defined$ Self | NumAtt$ +1 | NumDef$ +1
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Kindle

Kindle is defined as:

```text
Kindle 1—{1} ({1}, Exile this card from your graveyard: Create a 1/1 colorless Elemental creature token. Kindle only as a sorcery.)
```

Implementation:

```text
A:AB$ Token | TokenScript$ c_1_1_elemental | PrecostDesc$ Kindle 1 — | Cost$ 1 ExileFromGrave<1/CARDNAME/this card> | ActivationZone$ Graveyard | SorcerySpeed$ True | SpellDescription$ Create a 1/1 colorless Elemental creature token.
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Mirage

Mirage is defined as:

```text
Mirage {1}{W} (You may cast this spell as though it had flash for its mirage cost. If you do, sacrifice it at the beginning of the next cleanup step.)
```

Implementation:

```text
S:Mode$ Continuous | Affected$ Card.Self | MayPlay$ True | MayPlayAltManaCost$ 1 W | MayPlayWithFlash$ True | AffectedZone$ Hand | EffectZone$ Hand | Description$ Mirage {1}{W} (You may cast this spell as though it had flash for its mirage cost. If you do, sacrifice it at the beginning of the next cleanup step.)
T:Mode$ SpellCast | ValidCard$ Card.Self | ValidSA$ Spell.MayPlaySource | Static$ True | Execute$ MirageCleanup
SVar:MirageCleanup:DB$ DelayedTrigger | Mode$ Phase | Phase$ Cleanup | RememberObjects$ Self | TriggerDescription$ At the beginning of the next cleanup step, sacrifice it. | Execute$ TrigSacrifice
SVar:TrigSacrifice:DB$ SacrificeAll | Defined$ DelayTriggerRememberedLKI
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Menagerie

Menagerie is defined as:

```text
Menagerie — As long as there are five or more creature types among creatures you control, [...]
```

To check if Menagerie is active, you can check this var if it is greater or equal than 5:

```text
SVar:Menagerie:Count$Valid Creature.YouCtrl$CreatureType
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Motivate

Motivate is defined as:

```text
When this creature enters, you may motivate target creature with less power than this by putting X +1/+1 counters on it.
```

Implementation:

```text
T:Mode$ ChangesZone | Origin$ Any | Destination$ Battlefield | ValidCard$ Card.Self | Execute$ TrigMotivate | OptionalDecider$ You | TriggerDescription$ Motivate 2 (When this creature enters, you may motivate target creature with less power than this by putting two +1/+1 counters on it.)
SVar:X:Count$CardPower
SVar:TrigMotivate:DB$ PutCounter | Named$ Motivate | CounterType$ P1P1 | CounterNum$ 2 | ValidTgts$ Creature.powerLTX | TgtPrompt$ Select target creature
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Paranoia

Paranoia is defined as:

```text
Paranoia {G} (You may cast this spell for its paranoia cost when a permanent you control leaves the battlefield.)
```

Implementation:

```text
T:Mode$ ChangesZone | TriggerZones$ Hand | ValidCard$ Permanent.YouCtrl | Origin$ Battlefield | Destination$ Any | Execute$ PayParanoia | TriggerDescription$ Paranoia {G} (You may cast this spell for its paranoia cost when a permanent you control leaves the battlefield.)
SVar:PayParanoia:DB$ Play | Named$ Paranoia | PlayCost$ G | ValidSA$ Spell.Self | Controller$ You | ValidZone$ Hand | Optional$ True
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Rerun

Rerun is defined as:

```text
If you cast this from your hand, exile it as it resolves. Whenever a creature you control dies, you may cast this card from exile without paying its mana cost.
```

Implementation:

```text
R:Event$ Moved | ValidLKI$ Card.Self+wasCastFromHand | Origin$ Stack | Destination$ Graveyard | Fizzle$ False | ReplaceWith$ RerunExile | Description$ Rerun (If you cast this from your hand, exile it as it resolves. Whenever a creature you control dies, you may cast this card from exile without paying its mana cost.)
SVar:RerunExile:DB$ ChangeZone | Defined$ ReplacedCard | Origin$ Stack | Destination$ Exile | RememberChanged$ True | SubAbility$ RerunDelayTrig
SVar:RerunDelayTrig:DB$ DelayedTrigger | Mode$ ChangesZone | ValidCard$ Creature.YouCtrl | Origin$ Battlefield | Destination$ Graveyard | OptionalDecider$ You | RememberObjects$ Remembered | Execute$ CastRerun | TriggerDescription$ Whenever a creature you control dies, you may cast this card from exile without paying its mana cost.
SVar:CastRerun:DB$ Play | Defined$ Remembered | WithoutManaCost$ True
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Showcase

Showcase is defined as:

```text
Showcase {2}{W}{W} (Then if you cast this for its showcase cost, create a 1/1 red Bard creature token that can't block and exile this. Whenever it attacks, you may cast a free copy of this.)
```

Implementation:

Your main `A:SP$` link should have `SubAbility$ DBToken` to link with the Showcase part.

```text
S:Mode$ AlternativeCost | Named$ Showcase | ValidSA$ Spell.Self | EffectZone$ All | Cost$ 2 W W | Description$ Showcase {2}{W}{W} (Then if you cast this for its showcase cost, create a 1/1 red Bard creature token that can't block and exile this. Whenever it attacks, you may cast a free copy of this.)
SVar:DBToken:DB$ Token | ConditionCheckSVar$ AltCostPaid | TokenScript$ r_1_1_bard_cantblock | RememberTokens$ True | SubAbility$ DBEffect
SVar:DBEffect:DB$ Effect | ConditionCheckSVar$ AltCostPaid | RememberObjects$ Remembered | ImprintCards$ Self | Triggers$ TriggerShowcaseAttack,TriggerTokenMoved | Duration$ Permanent | SubAbility$ DBExile
SVar:TriggerShowcaseAttack:Mode$ Attacks | ValidCard$ Card.IsRemembered | Execute$ PlayShowcase | TriggerDescription$ Whenever the showcased creature attacks, you may cast a copy of EFFECTSOURCE without paying its mana cost.
SVar:PlayShowcase:DB$ Play | Defined$ Imprinted | WithoutManaCost$ True | CopyCard$ True | Optional$ True | OptionalDecider$ You 
SVar:TriggerTokenMoved:Mode$ ChangesZone | ValidCard$ Card.IsRemembered | ExcludedDestinations$ Battlefield | Execute$ ExileEffect | Static$ True
SVar:ExileEffect:DB$ ChangeZone | Defined$ Self | Origin$ Command | Destination$ Exile
SVar:DBExile:DB$ ChangeZone | ConditionCheckSVar$ AltCostPaid | Defined$ Self | Origin$ Stack | Destination$ Exile | SubAbility$ DBCleanup
SVar:DBCleanup:DB$ Cleanup | ClearRemembered$ True
SVar:AltCostPaid:Count$AltCost.1.0
```

### Torment

Torment is defined as:

```text
To torment yourself, lose 3 life unless you discard a card or sacrifice a nonland permanent.
```

Implementation:

```text
SVar:DBTorment:DB$ GenericChoice | Defined$ You | AILogic$ PayUnlessCost | Choices$ DBPaySac,DBPayDiscard | FallbackAbility$ DBLoseLifeFallback | SpellDescription$ Lose 3 life unless you discard a card or sacrifice a nonland permanent.
SVar:DBPaySac:DB$ LoseLife | LifeAmount$ 3 | Defined$ You | UnlessCost$ Sac<1/Permanent.nonland/nonland permanent> | UnlessPayer$ You | SpellDescription$ Lose 3 life unless you sacrifice a nonland permanent.
SVar:DBPayDiscard:DB$ LoseLife | LifeAmount$ 3 | Defined$ You | UnlessCost$ Discard<1/Card.Other/card> | UnlessPayer$ You | SpellDescription$ Lose 3 life unless you discard a card.
SVar:DBLoseLifeFallback:DB$ LoseLife | Defined$ You | LifeAmount$ 3
```

[Jump to top](#keywords-and-mechanisms-implementation)
