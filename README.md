![image](https://github.com/user-attachments/assets/e3d80b44-69b6-430a-b232-3170467280d3)

# DataCache - lightweight & private client data

DataCache is a strictly-typed, privacy-driven, lightweight cache of data for the LocalPlayer.

#### Overview
DataCache is part of a series of packages I have developed personally for usage in my template game that I use for fast-build commission works. It is designed to work with a specific hierarchy of RemoteEvents and RemoteFunctions, as documented in the file and later in this document. I am not in a place to release all of these packages, but I can release this one. These packages (this one included) are designed for rapid development of commission works.

#### Setup - extracted from in-file documentation
```
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
```

#### Wally
`datacache = "summerequinox/datacache@1.0.1"`

#### API
Publically, two methods are directly returned by the package (which can be thought of like a singleton of cached data, internals are held in a private table that is inaccessible externally).

```lua
--[[
Description: Retrieves the complete dataset stored in the DataCache.

Parameters:
    self: DataCache - The DataCache instance

Returns:
    Data - The complete dataset stored in the cache
]]
DataCache:getDataFull()

--[[
Description: Retrieves a specific portion of data from the DataCache by key.

Parameters:
    self: DataCache - The DataCache instance
    requestedDataKey: string - The key of the data to retrieve
    returnEmptyTableIfNotFound: boolean? - Optional parameter to return an empty table if the key is not found

Returns:
    any - The requested data value or an empty table if not found and returnEmptyTableIfNotFound is true
]]
DataCache:getDataPartial(dataKey: string, returnEmptyTableIfNotFound: boolean?)
```
