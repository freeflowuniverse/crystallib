-- Function to normalize strings (convert to lower case and replace spaces with underscores)
local function normalize(str)
    return string.gsub(string.lower(str), "%s+", "_")
end

local src = ARGV[1] and normalize(ARGV[1]) or nil

if src then
    -- Delete logs for specified source and category
    local logHashKey = "logs:" .. src
    local lastIdKey = logHashKey .. ":lastid"
    redis.call('DEL', logHashKey)
    redis.call('DEL', lastIdKey)
else
    -- Delete all logs for all sources and categories
    local keys = redis.call('KEYS', "logs:*")
    for i, key in ipairs(keys) do
        redis.call('DEL', key)
    end
end

return "Logs deleted"
