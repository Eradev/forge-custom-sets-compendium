# Tools

## forge-gen\.py

Used to generate editions files using [msem-instigator](https://msem-instigator.herokuapp.com).

> Note: The output might need some cleanup after generation as it is very crude.

Dependencies:

```text
pip install requests beautifulsoup4
```

Use:

```text
python forge-gen.py SET
```

## install\.ps1

Used to copy MSEM folders into Forge folders, overwriting old files.

> * By default, it will not copy the images files. Use args `-images $true` to also copy them.
> * Be sure to run the script inside the `tools` folder.

Use:

```text
.\install.ps1
```
