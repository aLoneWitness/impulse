-- luacheck: ignore 111

--- Hooks that can be used in a Plugin or a Schema
-- @hooks General

--- Controls wether a player can use their inventory, returning false stops all inventory interaction and stops the inventory from displaying
-- @realm shared
-- @entity ply The player that is trying to use their inventory
-- @treturn bool Can use inventory
function CanUseInventory(ply)
end


--- Called when a player opens their storage box
-- @realm server
-- @entity ply The player that has opened their storage
-- @entity box The storage box
function PlayerOpenStorage(ply, box)
end

--- Called when a player is un-arrested
-- @realm server
-- @entity convict The player that has been un-arrested
-- @entity officer The officer who un-arrested the player
function PlayerUnArrested(convict, officer)
end

--- Called when a player is arrested
-- @realm server
-- @entity convict The player that has been arrested
-- @entity officer The officer who arrested the player
function PlayerArrested(convict, officer)
end

--- Returns a custom death sound to override the default impulse one
-- @realm client
-- @treturn string Sound path
function GetDeathSound()
end

--- Called when you can define settings, all settings you want to define should be done inside this hook
-- @realm client
-- @see Setting
function DefineSettings()
end

--- Called when the menu is active and MenuMessages are ready to be created
-- @realm client
-- @see MenuMessage
function CreateMenuMessages()
end

--- Called when the menu is active and MenuMessages are ready to be displayed
-- @realm client
-- @internal
-- @see MenuMessage
function DisplayMenuMessages()
end

--- Called when the local player is sent to jail, provides jail sentence data
-- @realm client
-- @int endTime When the jail sentence will end
-- @param jailData Data regarding the sentence including crimes commited
function PlayerGetJailData()
end

--- Called when the player has fully loaded into the server after connecting
-- @realm server
-- @entity ply Player who is now fully connected
function PlayerInitialSpawnLoaded()
end

--- Called before a players inventory is queried from the database
-- @realm server
-- @entity ply The player
function PreEarlyInventorySetup()
end

--- Called after a players inventory has been setup
-- @realm server
-- @entity ply The player
function PostInventorySetup()
end

--- Called after a player has been fully setup by impulse
-- @realm server
-- @entity ply The player
function PostSetupPlayer()
end

--- Called when an in-character chat message is sent
-- @realm server
-- @entity sender The sender
-- @string message The message
-- @treturn string The new message
function ProcessICChatMessage()
end

--- Called when an chat class message is sent
-- @realm server
-- @int chatClass ID of the chat class
-- @entity sender The sender
-- @string message The message
-- @treturn string The new message
function ChatClassMessageSend()
end

--- Called after a chat class message is sent
-- @realm server
-- @int chatClass ID of the chat class
-- @string message The message
-- @entity sender The sender
function PostChatClassMessageSend()
end