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

-- Types
type Data = { [any]: any } | {}
type DataCache = {
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

local INITIALIZED_SIGNAL: BindableEvent = Instance.new("BindableEvent", script)

-- Variables
local currentlyInitializing: boolean = false

-- Cache
local DataCache: DataCache = {
	_initialized = false,
	_data = {},
	_methods = {},

	public_methods = {},
}

-- Functions
function onDataCacheUpdatedFull(data: Data)
    DataCache._data = data
end

function onDataCacheUpdatedPartial(dataKey: string, data: any)
    DataCache._data[dataKey] = data
end

-- Method Writing
function DataCache._methods:Initialize()
    if currentlyInitializing then
        INITIALIZED_SIGNAL.Event:Wait()
    end

	if DataCache._initialized then
		return
	end

    currentlyInitializing = true

    local data = NETWORK_FUNCTIONS.RequestDataCache:InvokeServer()

    NETWORK_EVENTS.DataCacheUpdatedFull.OnClientEvent:Connect(onDataCacheUpdatedFull)
    NETWORK_EVENTS.DataCacheUpdatedPartial.OnClientEvent:Connect(onDataCacheUpdatedPartial)

    DataCache._initialized = true
    DataCache._data = data

    currentlyInitializing = false

    INITIALIZED_SIGNAL:Fire()
end

function DataCache._methods:GetDataFull(): Data
    DataCache._methods:Initialize()
    return DataCache._data
end

function DataCache._methods:GetDataPartial(dataKey: string, returnEmptyTableIfNotFound: boolean?): Data | any | nil
    local data = DataCache._data[dataKey]

    if data == nil and returnEmptyTableIfNotFound then
        return {}
    end

    return data
end

-- Public Method Writing
function DataCache.public_methods:GetDataFull(): Data
	DataCache._methods:Initialize()
    return DataCache._methods:GetDataFull()
end

function DataCache.public_methods:GetDataPartial(dataKey: string, returnEmptyTableIfNotFound: boolean?): Data | any | nil
	DataCache._methods:Initialize()
    return DataCache._methods:GetDataPartial(dataKey, returnEmptyTableIfNotFound)
end

-- Initialize
DataCache._methods:Initialize()

-- Return Cache
return DataCache.public_methods
