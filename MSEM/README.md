# MSEM Sets

Sets released by [MSEM](https://snapdragonfirework.wixsite.com/msem2).

Set information can be found on [msem-instigator](https://msem-instigator.herokuapp.com).

## How to install?

* Drop the `custom` folder in `%appdata%\Forge`
* Drop the `pics` folder in `%appdata%\..\Local\Forge\cache`

## Keywords implementation

Examples on how to implement custom keywords

### Torment

```text
SVar:DBTorment:DB$ GenericChoice | Defined$ You | AILogic$ PayUnlessCost | Choices$ PaySac,PayDiscard | FallbackAbility$ LoseLifeFallback | SpellDescription$ Lose 3 life unless you discard a card or sacrifice a nonland permanent.
SVar:PaySac:DB$ LoseLife | LifeAmount$ 3 | Defined$ You | UnlessCost$ Sac<1/Permanent.nonland/nonland permanent> | UnlessPayer$ You | SpellDescription$ Lose 3 life unless you sacrifice a nonland permanent.
SVar:PayDiscard:DB$ LoseLife | LifeAmount$ 3 | Defined$ You | UnlessCost$ Discard<1/Card.Other/card> | UnlessPayer$ You | SpellDescription$ Lose 3 life unless you discard a card.
SVar:LoseLifeFallback:DB$ LoseLife | Defined$ You | LifeAmount$ 3
```
