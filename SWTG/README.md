# Star Wars: the Gathering

More information can be found on its [official website](https://www.starwarsthegathering.com).

> These sets contains custom creature and Planeswalker types. You need to add them every time you update Forge.

## Set implementation progress

```text
Star Wars: the Gathering (SWTG) - 100% (271/271)
```

## How to install?

### Manually

* Drop the `custom` folder in `%appdata%\Forge`;
* Drop the `pics` folder in `%appdata%\..\Local\Forge\cache`;
* Copy the custom types inside `custom\typelists\SWTG.txt` into `res\lists\TypeLists.txt` located under your Forge installation.

### Scripts (Powershell)

* Run the `install.ps1` script;
* Run the `install-custom-types.ps1` script.

## Keywords and mechanisms implementation

Examples on how to implement custom keywords and mechanisms.

* [Bounty](#bounty)
* [Hate](#hate)
* [Meditate](#meditate)
* [Repair](#repair)
* [Spaceflight](#spaceflight)

### Bounty

Bounty is defined as:

```text
Bounty — Whenever a creature an opponent controls with a bounty counter on it dies, [...]
```

Implementation:

```text
T:Mode$ ChangesZone | Origin$ Battlefield | Destination$ Graveyard | ValidCard$ Creature.OppCtrl+counters_GE1_BOUNTY | TriggerZones$ Battlefield | Execute$ TrigBounty | TriggerDescription$ Bounty — Whenever a creature an opponent controls with a bounty counter on it dies, [...]
SVar:TrigBounty:[...]

```

### Hate

Hate is defined as:

```text
Hate — [...], if an opponent lost life from a source other than combat damage this turn, [...]
```

To check for Hate, you can check this var if it is greater than 0:

```text
SVar:HateFlag:PlayerCountRegisteredOpponents$NonCombatDamageDealtThisTurn
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Meditate

Meditate is defined as:

```text
Meditate 1W (Return this creature to its owner's hand. Meditate only as a sorcery.)
```

Implementation

```text
A:AB$ ChangeZone | Named$ Meditate | Cost$ 1 W | ActivationZone$ Battlefield | SorcerySpeed$ True | Origin$ Battlefield | Destination$ Hand | Defined$ Self | SpellDescription$ Meditate (Return this creature to its owner's hand. Meditate only as a sorcery.)
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Repair

Repair is defined as:

```text
Repair 4 (When this creature dies, put four repair counters on it. At the beginning of your upkeep, remove a repair counter. Whenever the last is removed, you may cast it from your graveyard until end of turn.)
```

Implementation:

```text
T:Mode$ ChangesZone | Origin$ Battlefield | Destination$ Graveyard | ValidCard$ Card.Self | Execute$ TrigRepair | TriggerDescription$ When CARDNAME dies, put four repair counters on it.
SVar:TrigRepair:DB$ PutCounter | CounterType$ REPAIR | CounterNum$ 4 | Defined$ TriggeredCard
T:Mode$ Phase | Phase$ Upkeep | ValidPlayer$ You | ValidCard$ Card.Self+inGraveyard | CheckSVar$ RepairCount | SVarCompare$ GE1 | Execute$ TrigRemoveRepair | TriggerDescription$ At the beginning of your upkeep, if CARDNAME is in your graveyard with repair counters, remove a repair counter.
SVar:RepairCount:Count$CardCounters.REPAIR
SVar:TrigRemoveRepair:DB$ RemoveCounter | CounterType$ REPAIR | CounterNum$ 1 | Defined$ Self
T:Mode$ CounterRemoved | TriggerZones$ Graveyard | ValidCard$ Card.Self | CounterType$ REPAIR | NewCounterAmount$ 0 | Execute$ DBCast | TriggerDescription$ When the last repair counter is removed from this card, you may cast it until end of turn.
SVar:DBCast:DB$ Effect | StaticAbilities$ STPlay | ForgetOnMoved$ Graveyard | RememberObjects$ Self | Duration$ EndOfTurn
SVar:STPlay:Mode$ Continuous | MayPlay$ True | Affected$ Card.IsRemembered | AffectedZone$ Graveyard | Description$ Until end of turn, you may play EFFECTSOURCE.
```

[Jump to top](#keywords-and-mechanisms-implementation)

### Spaceflight

Spaceceflight is described as:

```text
Spaceflight (This creature can only block or be blocked by creatures with spaceflight.)
```

Implementation:

```text
K:Spaceflight
S:Mode$ Continuous | EffectZone$ Battlefield | Affected$ Card.Self+withSpaceflight | AddStaticAbility$ BlockSpaceflight
S:Mode$ Continuous | EffectZone$ Battlefield | Affected$ Card.Self+withSpaceflight | AddStaticAbility$ BlockBySpaceflight
SVar:BlockSpaceflight:Mode$ CantBlockBy | ValidAttacker$ Creature.withoutSpaceflight | ValidBlocker$ Creature.Self | Description$ CARDNAME can block only creatures with spaceflight.
SVar:BlockBySpaceflight:Mode$ CantBlockBy | ValidBlocker$ Creature.withoutSpaceflight+withoutSpacereach | ValidAttacker$ Creature.Self | Description$ CARDNAME can be blocked only by creatures with spaceflight.
```

> Spacereach is an internal keyword used to implement Exogorth.

[Jump to top](#keywords-and-mechanisms-implementation)
