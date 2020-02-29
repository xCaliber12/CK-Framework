local Proxy = module("libs/Proxy")
local Tunnel = module("libs/Tunnel")

API = {}
API.users = {} -- key: user_id | value: User.class
API.sources = {} -- key: source | value: user_id
API.identifiers = {} -- key: identifier | value: user_id
API.chars = {}

API.onFirstSpawn = {}

-- API Server Export
Proxy.addInterface("API", API)
Tunnel.bindInterface("API", API)
-- API_Database Export
Tunnel.bindInterface("API_DB", API_Database)
Proxy.addInterface("API_DB", API_Database)
cAPI = Tunnel.getInterface("API")

function API.getUserIdByIdentifiers(ids, name)
    local rows = API_Database.query("FCRP/SelectUser", {identifier = ids[1]})
    if #rows > 0 then
        return rows[1].user_id
    end

    local rows = API_Database.query("FCRP/CreateUser", {identifier = ids[1], name = name})
    if #rows > 0 then
        return rows[1].id
    end
end

function API.getUserFromUserId(user_id)
    return API.users[user_id]
end

function API.getUserFromSource(source)
    return API.users[API.sources[source]]
end

function API.getUserIdFromSourceIdentifier(source)
    if source ~= nil then
        local ids = GetPlayerIdentifiers(source)
        if ids ~= nil and #ids > 0 then
            return API.users[ids[1]]
        end
    end
    return nil
end

function API.getUserFromCharId(charid)
    if API.users[API.chars[tonumber(charid)]] then
        return API.users[API.chars[tonumber(charid)]]
    end
    return nil
end

function API.getUserIdFromCharId(charid)
    if API.chars[charid] then
        return API.chars[charid]
    else
        local rows = API_Database.query("FCRP/GetUserIdByCharId", {charid = charid})
        if #rows > 0 then
            return rows[1].user_id
        end
    end
    return nil
end

function API.getUsers()
    return API.users
end

function API.setBanned(user_id)
    if user_id ~= nil then
        API_Database.execute("FCRP/SetBanned", {user_id = user_id})
        DropPlayer(sourcePlayer, reason)
    end
end

function API.isBanned(user_id)
    local rows = API_Database.query("FCRP/BannedUser", {user_id = user_id})
    if #rows > 0 then
        return tonumber(rows[1].banned)
    else
        return false
    end
end

function API.isWhitelisted(identifier)
    local rows = API_Database.query("FCRP/Whitelisted", {identifier = identifier})
    return #rows > 0
end

function API.dropPlayer(source, reason)
    local User = API.getUserFromSource(source)
    if User then
        local user_id = User:getId()
        local steamID = GetPlayerIdentifiers(source)[1]
        API.users[user_id] = nil
        API.sources[source] = nil
        API.identifiers[steamID] = nil
        print(GetPlayerName(source) .. ' (' .. User:getIpAddress() .. ') desconectou (motivo = ' .. reason .. ')')
        User:saveCharacter()
    end
end

function API.kick(source, reason)
    API.dropPlayer(source, reason)
end
