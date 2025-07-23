# MSEM Sets

Sets released by [MSEM](https://snapdragonfirework.wixsite.com/msem2).

Set information can be found on [msem-instigator](https://msem-instigator.herokuapp.com).

## How to install?

* Drop the `custom` folder in `%appdata%\Forge`
* Drop the `pics` folder in `%appdata%\..\Local\Forge\cache`

## Keywords implementation

Examples on how to implement custom keywords

* [Motivate](#motivate)
* [Torment](#torment)

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