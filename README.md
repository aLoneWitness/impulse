![logo](https://cdn.impulse-community.com/logo_big.png)

© 2i games. All rights reserved. All trademarks are property of their respective owners in the UK and other countries.

# Welcome to impulse
impulse is a Semi-Serious roleplay framework for Garry's Mod.

## History
impulse is a semi-serious roleplay framework designed by vin (Jake Green) for Apex-Roleplay's Black Mesa gamemode and Half Life 2 gamemode after that. Impulse is the predecessor to Apex-Roleplay's version of Classic Half-Life 2 roleplay base. Impulse was created in an attempt to update  the in-efficient and dated code of Classic Half-Life 2 Roleplay's base, and in the process add new features like an inventory system and character customization. In contrast to the Classic Half-Life 2 roleplay's base impulse is not a derivative of any other gamemode/framework. After Apex-Roleplay's closed in 2018 independent development had continued intermitenally until Jan 2019 when vin started full work again on the framework, recoding almost all the elements previously implemented. Since 2019 development has rapidly continued with several core features and goals being reached, all of which are documented in dev logs which are posted at www.jakegreen.me. In March 2019 aLoneWitness joined to help with the HL2RP schema. In May 2019 private tests occured. Since May 2019 work continued and was heavily focused on the inventory system. In the months following May several features were overhauled to meet the standards of the rest of the framework such as the door system. Several months of bug fixing and polishing then occured until the 22nd of November 2019 when impulse launched to the public running the Half-Life 2 Roleplay schema. Since then impulse has been steadily progressing with systems such as achievements, containers, event managers and more being added. Most of these changes are logged in detail at www.news.impulse-community.com. impulse, as a framework is still in a relatively early state and is now being prepared for a public release of the source code.

## Working with impulse
Check out the docs at [Check out the docs](https://vingard.github.io/impulsedocs/). If you want to just get started read the ['Installing impulse' guide](https://vingard.github.io/impulsedocs/topics/00-installing.md.html).

### Understanding the builds load process
Currently, the build load process is very simple. The framework will look for a file called config.yml in the data folder, and if it exists it will merge it with the default developer database configuration. This system will probably be updated at some point to allow to to apply to config objects and other things.

### Running development builds
* Ensure mysqloov9 is installed
* Install XAMPP and create a database called impulse_development
* Using the default XAMPP root user the development build should connect automatically

### Running release builds (on a server)
* Ensure mysqloov9 is installed on the server
* Create your database and database user
* Navigate to data/impulse/config.yml (make these files or folders if they don't exist)
* Enter the YAML data below into config.yml and configure it for your database
* WARNING: Never use localhost instead use 127.0.0.1
* WARNING: SQL strict mode MUST BE DISABLED
```
db:
  ip: "IP HERE"
  username: "username"
  password: "pass123"
  database: "dbname"
  port: 3306
```

## Required plugins
chatbox_v2, ops

## License
Read the full license in the 'LICENSE' file.
