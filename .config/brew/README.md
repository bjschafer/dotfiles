# Brewfile shenanigans

This uses [yadm's templating feature](https://yadm.io/docs/templates#) to permit separate tracking of deps for various systems.
Currently, I do it based on class, so I get work vs everything else.

## TODO

Make maintaining these lists less manual. Probably wrap `brew bundle` and perhaps prompt for where to put a thing?
