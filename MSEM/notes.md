# Notes

Keep notes for other participants you think they might find useful.

## Possible/partial integration for Inscribe

Works, kinda. Unable to find related cards using Unearthly Grace. Haven't tested with all the rulings, particularly the last two:

```text
Inscribe (cost) ((cost): Exile this card from your hand inscribed on a creature you control. Whenever that creature attacks, its controller may cast a copy of the inscribed card without paying its mana cost. Inscribe only as a sorcery.)
• Inscribe represents an activated ability that functions while the card with inscribe is in its owner's hand and a static ability that functions while the card with inscribe is in the exile zone. "Inscribe (cost)" means "(cost): Exile this card from your hand inscribed on a creature you control. Activate this ability only at any time you could cast a sorcery." and "The creature this card is inscribed onto has 'Whenever this creature attacks, you may copy the inscribed card and you may cast the copy without paying its mana cost.'"
• If an inscribed card somehow leaves exile, it will no longer be inscribed on that creature.
• Cards with this ability have the subtype Inscription.
• If you copy an inscribe ability you control, only one of them will be able to exile the card from your hand and will the rest will do nothing.
• If you gain control of or copy an inscribe ability of a card you don't own, you will be unable to exile the card and the ability will do nothing.
```

```text
A:AB$ Effect | Cost$ 2 W ExileFromHand<1/CARDNAME/this card> | ActivationZone$ Hand | ValidTgts$ Creature.YouCtrl | TgtPrompt$ Select target creature you control | SorcerySpeed$ True | RememberObjects$ Targeted | StaticAbilities$ STInscribeDesc | Triggers$ InscribeTrigger,InscriptionRemovedFromExile | ImprintCards$ Self | Duration$ Permanent | ForgetOnMoved$ Battlefield | SpellDescription$ Inscribe ({2}{W}: Exile this card from your hand inscribed on a creature you control. Whenever that creature attacks, its controller may cast a copy of the inscribed card without paying its mana cost. Inscribe only as a sorcery.)
SVar:STInscribeDesc:Mode$ Continuous | Affected$ Card.IsRemembered | Secondary$ True | AddStaticAbility$ InscribeOnCreature
SVar:InscribeOnCreature:Mode$ Continuous | Affected$ Card.Self | AddSVar$ SVarInscribed | Description$ Inscribed — Inner Peace
SVar:InscribeTrigger:Mode$ Attacks | ValidCard$ Card.IsRemembered | Execute$ PlayInscribed | TriggerDescription$ Whenever the inscribed creature attacks, you may cast a copy of EFFECTSOURCE without paying its mana cost.
SVar:PlayInscribed:DB$ Play | Defined$ Imprinted | WithoutManaCost$ True | CopyCard$ True | Optional$ True | OptionalDecider$ You SVar:InscriptionRemovedFromExile:Mode$ ChangesZone | Origin$ Exile | TriggerZones$ Exile | ValidCard$ Card.IsImprinted | Execute$ ExileEffect | Static$ True
SVar:ExileEffect:DB$ ChangeZone | Destination$ Exile | Defined$ Self
SVar:SVarInscribed:SVar:IsInscribed:TRUE
```

## Booster definition

From cajun (Discord)

```text
(standard)
draft-booster
AFM-EOW, HQZ, BLR

play-booster
ROS-onward

bonus-draft-booster
10 common, 3 uncommon, 1 rare/mythic, 1 bonus
VTM, WAY, RVO

exclusive-land-slot-draft-booster
9 nonland commons, 3 uncommons, 1 rare/mythic, 1 common land
ALK

(all rares)
all-rares-nwo-booster
10 rares, with 1 possibly rolling a mythic
CAC, MAC, STN, VHS, RCM, SPK
101 also uses this but technically would be a box set with 1/each card

cubelike-nwo-booster
15 rares
DOA

headliner
8 rares
TMI

(specialized)
SWR-draft-booster
9 common, 3 uncommon, 1 uncommon legend, 1 rare/mythic, 1 rare/mythic legend
SWR

KXP-draft-booster
10 nonland commons, 3 uncommon, 1 non-Codex rare/mythic, 1 common land
KXP

AVX-draft-booster
9 common, 3 uncommon, 1 rare/mythic, 33% chance to replace a common with a B-Side
AVX
```

```text
then lackeybot's implementation of draft and play is

Draft
10 common
3 uncommon
1 rare/mythic (13.5%)
1 basic land, or common if set doesn't have any

Play
7 common (supports 1.5% chance to replace one with a Special Guest, though unused in MSEM)
3 uncommon
1 rare/mythic (14.28%)
1 wildcard (70%c, 17.5%u, 10.714%r, 1.786%m)
1 foil wildcard (60%c, 25%u, 12.86%r, 2.14%m)
1 basic land, or noting if set doesn't have any
```
