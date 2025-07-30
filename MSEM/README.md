# MSEM Sets

Sets released by [MSEM](https://snapdragonfirework.wixsite.com/msem2).

Set information can be found on [msem-instigator](https://msem-instigator.herokuapp.com).

## How to install?

* Drop the `custom` folder in `%appdata%\Forge`
* Drop the `pics` folder in `%appdata%\..\Local\Forge\cache`

## Set implementation progress

```text
Video Horror System (VHS) -  26% (23/86)
The Land Bundle (L)       - 100% (80/80)
Tides of War (TOW)        -  27% (75/271)
```

## Keywords implementation

Examples on how to implement custom keywords

* [Horrific](#horrific)
* [Kindle](#kindle)
* [Motivate](#motivate)
* [Paranoia](#paranoia)
* [Torment](#torment)

### Horrific

Horrific is defined as:

```text
You're horrific as long as you've sacrificed a permanent or discarded a card this turn.
```

To check if you're horrific, you can check this var if it is greater than 0:

```text
SVar:Horrific:PlayerCountPropertyYou$SacrificedThisTurn Permanent/Plus.PlayerCountPropertyYou$CardsDiscardedThisTurn
```

### Kindle

Kindle is defined as:

```text
Kindle 1—{1} ({1}, Exile this card from your graveyard: Create a 1/1 colorless Elemental creature token. Kindle only as a sorcery.)
```

Implementation:

```text
A:AB$ Token | TokenScript$ c_1_1_elemental | PrecostDesc$ Kindle 1 — | Cost$ 1 ExileFromGrave<1/CARDNAME> | ActivationZone$ Graveyard | SorcerySpeed$ True | SpellDescription$ Create a 1/1 colorless Elemental creature token. Kindle only as a sorcery.
```

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

[Jump to top](#keywords-implementation)

### Paranoia

Paranoia is defined as:

```text
Paranoia {G} (You may cast this spell for its paranoia cost when a permanent you control leaves the battlefield.)
```

Implementation:

```text
T:Mode$ ChangesZone | TriggerZones$ Hand | ValidCard$ Permanent.YouCtrl | Origin$ Battlefield | Destination$ Any | Execute$ PayParanoia | TriggerDescription$ Paranoia {G} (You may cast this spell for its paranoia cost when a permanent you control leaves the battlefield.)
SVar:PayParanoia:DB$ Play | PlayCost$ G | ValidSA$ Spell.Self | Controller$ You | ValidZone$ Hand | Optional$ True
```

[Jump to top](#keywords-implementation)

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

[Jump to top](#keywords-implementation)
