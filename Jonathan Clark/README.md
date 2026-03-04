# Jonathan Clark

Custom cards designed by Jonathan Clark

More information can be found on their [Facebook Group](https://www.facebook.com/groups/395579408681224/user/100022663929074).

## Set implementation progress

```text
Ben 10 Commander - Hero Time! (OMV) - 100%
```

## How to install?

### Manually

* Drop the `custom` folder in `%appdata%\Forge`;
* Drop the `pics` folder in `%localappdata%\Forge\cache`;

### Scripts (Powershell)

* Run the `install.ps1` script;

## Keywords and mechanisms implementation

Examples on how to implement custom keywords and mechanisms.

### Omnishuffle

Omnishuffle is defined as:

```text
Omnishuffle X (If this card would be put into a graveyard from anywhere, reveal it, then shuffle it into its owner's library instead. Its owner loses X life.)
```

Implementation:

```text
R:Event$ Moved | Destination$ Graveyard | ValidCard$ Card.Self | ReplaceWith$ DBOmniShuffle | Description$ Omnishuffle 1 (If NICKNAME would be put into a graveyard from anywhere, reveal it, then shuffle it into its owner's library instead. Its owner loses 1 life.)
SVar:DBOmniShuffle:DB$ ChangeZone | Hidden$ True | Origin$ All | Destination$ Library | Defined$ ReplacedCard | Reveal$ True | Shuffle$ True | SubAbility$ DBLoseLife
SVar:DBLoseLife:DB$ LoseLife | LifeAmount$ 1
```
