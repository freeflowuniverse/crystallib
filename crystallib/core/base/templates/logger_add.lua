
local function normalize(str)
    return string.gsub(string.lower(str), "%s+", "_")
end

local src = normalize(ARGV[1])
local category = normalize(ARGV[2])
local message = ARGV[3]
local logHashKey = "logs:" .. src
local lastIdKey = "logs:" .. src .. ":lastid"

-- redis.log(redis.LOG_NOTICE, "...")

-- Increment the log ID using Redis INCR command
local logId = redis.call('INCR', lastIdKey)

-- Get the current epoch time
local epoch = redis.call('TIME')[1]

-- Prepare the log entry with a unique ID, epoch time, and message
local logEntry = category .. ":" .. epoch .. ":" .. message

-- Add the new log entry to the hash set
redis.call('HSET', logHashKey, logId, logEntry)

-- Optionally manage the size of the hash to keep the latest 2000 entries only
local hlen = redis.call('HLEN', logHashKey)
if hlen > 5000 then
    -- Find the smallest logId
    local smallestId = logId
    local cursor = "0"
    repeat
        local scanResult = redis.call('HSCAN', logHashKey, cursor, "COUNT", 5)
        cursor = scanResult[1]
        local entries = scanResult[2]
        for i = 1, #entries, 2 do
            local currentId = tonumber(entries[i])
            if currentId < smallestId then
                smallestId = currentId
            end
        end
    until cursor == "0"
    -- redis.log(redis.LOG_NOTICE, "smallest id: " .. smallestId)
    
    -- Remove the oldest entries
    for i = smallestId, smallestId + 500 do
        redis.call('HDEL', logHashKey, i)
    end
end

return logEntry
