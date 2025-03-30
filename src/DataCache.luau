-- Repository: https://github.com/SummerEquinox/DataCache
-- Wally: https://wally.run/package/summerequinox/datacache

-- For contributions and PRs, note that the file is wrote using the Roblox Lua Style Guide:
-- https://roblox.github.io/lua-style-guide/

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
    I may make public the server-side of this code in the future. But for all intents and purposes, if you are using ProfileService or ProfileStore,
    your update function should make the update and then send a partial update so all caches receive the new data.

    Full cache updates are wired up here, but you can get away without using them, it just depends on your needs.
]]

--[[
    Please note as well that your ReplicatedStorage Network folder must at least be set up as follows for proper functionality:

    ./ReplicatedStorage/Network/
        ./DataCache/

            ./Functions/
                ./RequestDataCache: RemoteFunction

            ./Events/
                ./DataCacheUpdatedFull: RemoteEvent
                ./DataCacheUpdatedPartial: RemoteEvent

    Your other folders in Network do not matter.
]]

--!strict

-- In-File Types
type Data = { [any]: any } | {}
type DataCache = {
	public: { [string]: (...any) -> ...any },
	private: {
		_initialized: boolean,
		_data: Data,
		_methods: { [string]: (...any) -> ...any },
	},
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local DATA_CACHE_NETWORK_ROOT = ReplicatedStorage:WaitForChild("Network"):WaitForChild("DataCache")

local NETWORK_FUNCTIONS = DATA_CACHE_NETWORK_ROOT:WaitForChild("Functions")
local NETWORK_EVENTS = DATA_CACHE_NETWORK_ROOT:WaitForChild("Events")

-- Functions
local function onDataCacheUpdatedFull(dataCachePrivate, fullDataset: Data)
	dataCachePrivate._data = fullDataset
end

local function onDataCacheUpdatedPartial(dataCachePrivate, dataKey: string, dataValue: any)
	dataCachePrivate._data[dataKey] = dataValue
end

-- Cache
local DataCache: DataCache = {
	public = {},
	private = {
		_initialized = false,
		_data = {},
		_methods = {},
	},
}

-- Cache Methods

--[[
Description: Initializes the DataCache by requesting initial data from the server and setting up event listeners for data updates.

Parameters:
    self: DataCache - The DataCache instance

Returns:
    None
]]
function DataCache.private._methods.initialize(self: DataCache)
	local data = NETWORK_FUNCTIONS.RequestDataCache:InvokeServer()

	NETWORK_EVENTS.DataCacheUpdatedFull.OnClientEvent:Connect(function(incomingDataFull: Data)
		onDataCacheUpdatedFull(DataCache.private, incomingDataFull)
	end)

	NETWORK_EVENTS.DataCacheUpdatedPartial.OnClientEvent:Connect(
		function(incomingDataKey: string, incomingDataValue: any)
			onDataCacheUpdatedPartial(DataCache.private, incomingDataKey, incomingDataValue)
		end
	)

	DataCache.private._initialized = true
	DataCache.private._data = data
end

--[[
Description: Retrieves the complete dataset stored in the DataCache.

Parameters:
    self: DataCache - The DataCache instance

Returns:
    Data - The complete dataset stored in the cache
]]
function DataCache.private._methods.getDataFull(self: DataCache): Data
	return DataCache.private._data
end

--[[
Description: Retrieves a specific portion of data from the DataCache by key.

Parameters:
    self: DataCache - The DataCache instance
    requestedDataKey: string - The key of the data to retrieve
    returnEmptyTableIfNotFound: boolean? - Optional parameter to return an empty table if the key is not found

Returns:
    any - The requested data value or an empty table if not found and returnEmptyTableIfNotFound is true
]]
function DataCache.private._methods.getDataPartial(self: DataCache, requestedDataKey: string, returnEmptyTableIfNotFound: boolean?): any
	local data = DataCache.private._data[requestedDataKey]

	if data == nil and returnEmptyTableIfNotFound then
		return {}
	end

	return data
end

--[[
Description: Public method to retrieve the complete dataset stored in the DataCache.

Parameters:
    self: DataCache - The DataCache instance

Returns:
    Data - The complete dataset stored in the cache
]]
function DataCache.public.getDataFull(self: DataCache): Data
	return DataCache.private._methods:getDataFull()
end

--[[
Description: Public method to retrieve a specific portion of data from the DataCache by key.

Parameters:
    self: DataCache - The DataCache instance
    dataKey: string - The key of the data to retrieve
    returnEmptyTableIfNotFound: boolean? - Optional parameter to return an empty table if the key is not found

Returns:
    any - The requested data value or an empty table if not found and returnEmptyTableIfNotFound is true
]]
function DataCache.public.getDataPartial(self: DataCache, dataKey: string, returnEmptyTableIfNotFound: boolean?): any
	return DataCache.private._methods:getDataPartial(dataKey, returnEmptyTableIfNotFound)
end

-- Initialize
DataCache.private._methods:initialize()

-- Return Cache
return DataCache.public