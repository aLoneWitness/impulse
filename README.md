# Welcome to impulse
**REDISTRIBUTION IS NOT PERMITTED, DO NOT DOWNLOAD, SHARE OR FORK**

## History
impulse is a semi-serious roleplay framework designed by vin (Jake Green) for Apex-Roleplay's Black Mesa gamemode and Half Life 2 gamemode after that. Impulse is the predecessor to Apex-Roleplay's version of Classic Half-Life 2 roleplay base. Impulse was created in an attempt to update  the in-efficient and dated code of Classic Half-Life 2 Roleplay's base, and in the process add new features like an inventory system and character customization. In contrast to the Classic Half-Life 2 roleplay's base impulse is not a derivative of any other gamemode/framework. After Apex-Roleplay's closed in 2018 independent development had continued intermitenally until Jan 2019 when vin started full work again on the framework, recoding almost all the elements previously implemented. Since 2019 development has rapidly continued with several core features and goals being reached, all of which are documented in dev logs which are posted at www.vingard.ovh. In March 2019 aLoneWitness joined to help with the HL2RP schema. In May 2019 private tests occured. Since May 2019 work has continued and has been focused heavily on the inventory system.

## Working with impulse
If your working with impulse I reccomend you read the wiki first, feel free to DM me on discord if you have any questions.

### Understanding the builds load process
Currently, the build load process is very simple. The framework will look for a file called database.json in the data folder, and if it exists it will merge it with the default developer database configuration. This system will probably be updated at some point to allow to to apply to config objects and other things.

### Running development builds
* Ensure mysqloov9 is installed
* Install XAMPP and create a database called impulse_development
* Using the default XAMPP root user the development build should connect automatically

### Running release builds (on a server)
* Ensure mysqloov9 is installed on the server
* Create your database and database user
* Navigate to data/impulse/database.json (make these files or folders if they don't exist)
* Enter the JSON data below into database.json and configure it for your database
* WARNING: Never use localhost instead use 127.0.0.1
```
{
	"ip": "127.0.0.1",
	"username": "impulsehl2rp",
	"password": "dsdsds",
	"database": "impulsehl2rp",
	"port": 3306.0
}
```

## Required plugins
chatbox_v2, ops

## License
Read the full license in the 'LICENSE' file.
tl;dr **this gamemode is private, do not download it, fork it or redistribute it in any way**. If you want permission you must ask vin.
