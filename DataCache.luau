-- SummerEquinox
-- DataCache.luau

-- This file is not currently hosted on Wally.
-- Repository: https://github.com/SummerEquinox/DataCache

--[[
    DataCache is a lightweight unit-ified cache of the data for the LocalPlayer.

    It is designed to be useable multiple times if necessary. Once required, it will request an initial cache from the server with a RemoteFunction,
    and then receive updates dynamically to the data from a RemoteEvent.
]]

--[[
    If data has not been initialized when data is requested, the called public method will yield until the data is initialized. It will then
    be returned if found. Otherwise, it will be instant.
]]

--[[
    Please note as well that your ReplicatedStorage Network folder must at least be set up as for proper functionality:

    ./ReplicatedStorage/Network/
        ./DataCache/

            ./Functions/
                ./RequestDataCache: RemoteFunction

            ./Events/
                ./DataCacheUpdatedFull: RemoteEvent
                ./DataCacheUpdatedPartial: RemoteEvent

    Your other folders in Network do not matter.
]]

-- Types
type Data = { [any]: any } | {}

export type DataCache = {
    _initialized: boolean,
    _data: Data,
    _methods: { [string]: (any...) -> any... } | {},

    public_methods: { [string]: (any...) -> any... } | {},
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local DATA_CACHE_NETWORK_ROOT: Folder = ReplicatedStorage:WaitForChild("Network"):WaitForChild("DataCache")

local NETWORK_FUNCTIONS: Folder = DATA_CACHE_NETWORK_ROOT:WaitForChild("Functions")
local NETWORK_EVENTS: Folder = DATA_CACHE_NETWORK_ROOT:WaitForChild("Events")

-- Cache
local DataCache: DataCache = {
    _initialized = false,
    _data = {},
    _methods = {},

    public_methods = {},
}

-- Method Writing
function DataCache._methods:Initialize()
    if DataCache._initialized then
        return
    end


end

-- Public Method Writing
function DataCache.public_methods:GetDataFull(): Data
    -- All public methods will yield if data is not initialized yet.

    -- Ensure data cache has been initialized
    DataCache._methods:Initialize()
end

function DataCache.public_methods:GetDataPartial(dataKey: string, returnEmptyTableIfNotFound: boolean?): Data | any | nil
    -- All public methods will yield if data is not initialized yet.

    -- Ensure data cache has been initialized
    DataCache._methods:Initialize()
end

-- Return Cache
return DataCache.public_methods
