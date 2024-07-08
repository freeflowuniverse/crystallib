local function update_stat(key, value, timestamp)
    local halflife = 3600  -- 1 hour, adjust as needed
    local window_size = 100  -- Size of sliding window
    
    -- Fetch current state
    local state = redis.call('HGETALL', key..':state')
    local state_dict = {}
    for i = 1, #state, 2 do
        state_dict[state[i]] = state[i+1]
    end
    
    local last_update = tonumber(state_dict['last_update'] or 0)
    local old_avg = tonumber(state_dict['ema'] or value)
    
    -- Calculate alpha based on time since last update
    local delta_t = timestamp - last_update
    local alpha = 1 - math.exp(-delta_t / halflife)
    
    -- Update EMA
    local new_avg = alpha * value + (1 - alpha) * old_avg
    
    -- Update sliding window
    redis.call('LPUSH', key..':window', value)
    redis.call('LTRIM', key..':window', 0, window_size - 1)
    
    -- Calculate additional statistics from window
    local window = redis.call('LRANGE', key..':window', 0, -1)
    local sum = 0
    local sum_sq = 0
    local min = value
    local max = value
    for _, v in ipairs(window) do
        v = tonumber(v)
        sum = sum + v
        sum_sq = sum_sq + v * v
        min = math.min(min, v)
        max = math.max(max, v)
    end
    local count = #window
    local mean = sum / count
    local variance = (sum_sq / count) - (mean * mean)
    local stddev = math.sqrt(variance)
    
    -- Prepare new state
    local new_state = {
        ema = new_avg,
        last_update = timestamp,
        window_min = min,
        window_max = max,
        window_mean = mean,
        window_stddev = stddev
    }
    
    -- Update hourly snapshots
    local current_hour = math.floor(timestamp / 3600)
    local last_hour = tonumber(state_dict['last_hour'] or 0)
    if current_hour > last_hour then
        redis.call('HSET', key..':hourly', last_hour, state_dict['ema'] or new_avg)
        redis.call('HSET', key..':hourly', current_hour, new_avg)
        new_state['last_hour'] = current_hour
        
        -- Keep only the last two hours
        local hours = redis.call('HKEYS', key..':hourly')
        table.sort(hours)
        if #hours > 2 then
            for i = 1, #hours - 2 do
                redis.call('HDEL', key..':hourly', hours[i])
            end
        end
    end
    
    -- Update daily snapshots
    local current_day = math.floor(timestamp / 86400)
    local last_day = tonumber(state_dict['last_day'] or 0)
    if current_day > last_day then
        redis.call('HSET', key..':daily', last_day, state_dict['ema'] or new_avg)
        redis.call('HSET', key..':daily', current_day, new_avg)
        new_state['last_day'] = current_day
        
        -- Keep only the last two days
        local days = redis.call('HKEYS', key..':daily')
        table.sort(days)
        if #days > 2 then
            for i = 1, #days - 2 do
                redis.call('HDEL', key..':daily', days[i])
            end
        end
    end
    
    -- Store new state
    for k, v in pairs(new_state) do
        redis.call('HSET', key..':state', k, v)
    end
    
    return new_avg
end

return update_stat(KEYS[1], tonumber(ARGV[1]), tonumber(ARGV[2]))