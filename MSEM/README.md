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
* Drop the `pics` folder in `%appdata%\..\Local\Forge\cache`;

### Scripts (Powershell)

* Run the `install.ps1` script;

## Set implementation progress

```text
Video Horror System (VHS)             -  95% (82/86)
  Missing cards:
    * Maddened Preacher
    * Snowfield Doppelganger
    * Wiretapper
    * Mr. Jackston, the Proprietor
Kaleidoscope (KLC)                    -  99% (107/108)
  Missing cards:
    * Tears of Samang
Path of Shadows (PSA)                 -  35% (76/214)
A Tourney at Whiterun (TWR)           -  11% (32/269)
Tides of War (TOW)                    -  28% (77/271)
Pyramids of Atuum (POA)               -  50% (64/128)

Reprints / Promo sets:
MSEM Champions (CHAMPIONS)
MSEM Champions: Masterpiece (MPS_MSE)
MSEM Secret Lair Drops (LAIR)
The Land Bundle (L)
```

## Keywords and mechanisms implementation

Examples on how to implement custom keywords and mechanisms.

* [Ascend](#ascend)
* [Bleed](#bleed)
* [Fleeting](#fleeting)
* [Horrific](#horrific)
* [Kindle](#kindle)
* [Mirage](#mirage)
* [Motivate](#motivate)
* [Paranoia](#paranoia)
* [Rerun](#rerun)
* [Torment](#torment)

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

### Bleed

Bleed is defined as:

```text
Bleed {1}{U} (You may cast this spell for its bleed cost if an opponent lost life this turn.)
```

Implementation:

```text
S:Mode$ Continuous | Affected$ Card.Self | MayPlayAltManaCost$ 1 U | MayPlay$ True | CheckSVar$ Bleed | SVarCompare$ GE1 | AffectedZone$ Hand | EffectZone$ Hand | Description$ Bleed {1}{U} (You may cast this spell for its bleed cost if an opponent lost life this turn.)
SVar:Bleed:Count$LifeOppsLostThisTurn
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
SVar:MirageCleanup:DB$ DelayedTrigger | Mode$ Phase | Phase$ Cleanup | RememberObjects$ Self | TriggerDescription$ At the beginning of the next cleanup step, sacrifice CARDNAME. | Execute$ TrigSacrifice
SVar:TrigSacrifice:DB$ SacrificeAll | Defined$ DelayTriggerRememberedLKI
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Motivate

Motivate is defined as:

```text
When this creature enters, you may motivate target creature with less power than this by putting X +1/+1 counters on it.
```

Implementation:

```text
K:Motivate:2
T:Mode$ ChangesZone | Origin$ Any | Destination$ Battlefield | ValidCard$ Card.Self | Execute$ TrigPutCounter | OptionalDecider$ You | TriggerDescription$ When this creature enters, you may motivate target creature with less power than this by putting two +1/+1 counters on it.
SVar:X:Count$CardPower
SVar:TrigPutCounter:DB$ PutCounter | CounterType$ P1P1 | CounterNum$ 2 | ValidTgts$ Creature.powerLTX | TgtPrompt$ Select target creature
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

> Note: Rerun allows a card to be cast from exile regardless of how it got there or from where.

Implementation:

```text
SVar:ExileSelf:DB$ ChangeZone | Origin$ Stack | Destination$ Exile | ConditionDefined$ Self | ConditionPresent$ Card.wasCastFromYourHandByYou

T:Mode$ ChangesZone | Origin$ Battlefield | Destination$ Graveyard | ValidCard$ Creature.YouCtrl | TriggerZones$ Exile | Execute$ CastRerun | TriggerDescription$ Rerun (If you cast this from your hand, exile it as it resolves. Whenever a creature you control dies, you may cast this card from exile without paying its mana cost.)
SVar:CastRerun:DB$ Play | Defined$ Self | Amount$ 1 | Controller$ You | WithoutManaCost$ True | Optional$ True | ActivationZone$ Exile
```

[Jump to top](#keywords-and-mechanisms-implementation)

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
