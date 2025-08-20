# MSEM Sets

Sets part of [MSEM](https://snapdragonfirework.wixsite.com/msem2).

Sets information can be found on [lackeybot](https://lackeybot.com/msem/search).

> These sets contains custom creature and Planeswalker types. You need to add them every time you update Forge.

## Changes

These changes might not be reflected in their official ruling.

* All Hounds are now Dogs. This also apply to abilities that target and/or applies to Hounds.

## How to install?

### Manually

* Drop the `custom` folder in `%appdata%\Forge`;
* Drop the `pics` folder in `%appdata%\..\Local\Forge\cache`;
* Copy the custom types inside `custom\typelists\MSEM.txt` into `res\lists\TypeLists.txt` located under your Forge installation.

### Scripts (Powershell)

* Run the `install.ps1` script;
* Run the `install-custom-types.ps1` script.

## Set implementation progress

```text
Video Horror System (VHS)             -  26% (23/86)
MSEM Champions (CHAMPIONS)            -  16% (24/146)
MSEM Champions: Masterpiece (MPS_MSE)
Kaleidoscope (KLC)                    -  65% (71/108)
A Tourney at Whiterun (TWR)           -  11% (31/269)
The Land Bundle (L)                   - 100% (80/80)
Tides of War (TOW)                    -  28% (77/271)
Pyramids of Atuum (POA)               -  15% (20/128)
```

## Keywords and mechanisms implementation

Examples on how to implement custom keywords and mechanisms.

* [Horrific](#horrific)
* [Kindle](#kindle)
* [Mirage](#mirage)
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

[Jump to top](#keywords-and-mechanisms-implementation)

### Kindle

Kindle is defined as:

```text
Kindle 1—{1} ({1}, Exile this card from your graveyard: Create a 1/1 colorless Elemental creature token. Kindle only as a sorcery.)
```

Implementation:

```text
A:AB$ Token | TokenScript$ c_1_1_elemental | PrecostDesc$ Kindle 1 — | Cost$ 1 ExileFromGrave<1/CARDNAME> | ActivationZone$ Graveyard | SorcerySpeed$ True | SpellDescription$ Create a 1/1 colorless Elemental creature token.
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
SVar:PayParanoia:DB$ Play | PlayCost$ G | ValidSA$ Spell.Self | Controller$ You | ValidZone$ Hand | Optional$ True
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
