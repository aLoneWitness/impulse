© 2i games. All rights reserved. All trademarks are property of their respective owners in the UK and other countries.

### This repo is archived and there will be NO SUPPORT. It has the MIT license, use it however you like, just don't remove the credits or the branding of the 'impulse' framework.

# Welcome to impulse
impulse is a Semi-Serious roleplay framework for Garry's Mod.

## Working with impulse
[Check out the docs](https://vingard.github.io/impulsedocs/). If you want to just get started read the ['Installing impulse' guide](https://vingard.github.io/impulsedocs/topics/00-installing.md.html). **The docs are VERY incomplete! Look through (search) the source code of the framework for full documentation!**

### Schemas
* [impulseskeleton](https://github.com/vingard/impulseskeleton) - Use this schema as a template for your schema! Shows the basics of schemas.
* [impulsehl2rpoutlands](https://github.com/vingard/impulsehl2rpoutlands) - Unfinished schema, will not work without impulsehl2rp (which has not been released). Good demonstration of the PiggyBoot system.
* [impulsestanleyrp](https://github.com/lokachop/impulsestanleyrp) - A basic schema by Lokachop, pretty simple example.

### Understanding the builds load process
Currently, the build load process is very simple. The framework will look for a file called config.yml in the data folder, and if it exists it will merge it with the default developer database configuration. This system will probably be updated at some point to allow to to apply to config objects and other things.

### Known issues
data/config.yml will cause an error on load if its is empty!

## License
Read the full license in the 'LICENSE' file.
