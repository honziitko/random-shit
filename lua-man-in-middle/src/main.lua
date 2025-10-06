local socket = require("socket")
local argparse = require("argparse")

local parser = argparse()
parser:argument("ip", "IP to connect to or if -h specified, the website name")
parser:argument("port", "Port to connect to. Default 80 for HTTP and 443 for HTTPS", nil, nil, "?")
parser:flag("-H --hypertext", "Connect to a website rather than raw dogging some TCP")
parser:flag("-s --secure", "Enctrypt traffic from self to server")
parser:flag("-S --super-secure", "Ebcrypt traffic from both browser and server (Note: not supported)")

local args = parser:parse()

local ip = args.ip
local hypertext = args.hypertext or false
local superSecure = args.super_secure or false
if superSecure then
    io.stderr:write("Sorry mate, enabling this just errors out with \"no shared cipher\"\n")
    os.exit(1)
end
local secure = superSecure or args.secure
local port;
if args.port then
    port = assert(tonumber(args.port))
elseif hypertext then
    if secure then
        port = 443
    else
        port = 80
    end
else
    io.stderr:write("When raw dogging TCP, port must be provided\n")
    os.exit(1)
end

if not port then
    print(string.format("%s is not a valid port", arg[2]))
    return
end

local server = assert(socket.bind("127.0.0.1", 0))

local function stringifySocket(sock)
    -- local ip, port = sock:getsockname()
    -- return string.format("%s:%d", ip, port)
    return string.format("%s:%d", sock:getsockname())
end

local serverURLName = stringifySocket(server)

local function stringIf(s, b)
    return (b and s) or ""
end
print(stringIf("https://", superSecure) .. serverURLName)

local function receiveFromSocket(sock, arg)
    return sock:receive(arg)
    -- while true do
    --     local s, err = sock:receive(arg)
    --     if err == "wantread" then
    --         -- socket.select({ sock }, nil)
    --     elseif err == "wantwrite" then
    --         -- socket.select(nil, { sock })
    --     else
    --         return s, err
    --     end
    -- end
end

local function nonBlockingRead(sock)
    sock:settimeout(0)
    local acc = nil
    while true do
        -- local data, err = sock:receive(1)
        local data, err = receiveFromSocket(sock, 1)
        if err ~= nil then
            if err == "timeout" or err == "wantread" then --wantread is the encrypted version of timeout
                return acc, nil
            end
            return nil, err
        end
        acc = (acc or "") .. data
    end
end

local function assertNonBlockingRead(sock)
    local data, err = nonBlockingRead(sock)
    if data == nil and err ~= nil then
        -- error(string.format("Error reveiving %s: %s", stringifySocket(sock), err))
        error(string.format("Error reveiving: %s", err))
    end
    return data
end

local function encrypConnection(sock, mode)
    local ssl = require("ssl")

    local params = {
        mode = mode,
        protocol = "any",
    }

    sock = assert(ssl.wrap(sock, params))
    sock:settimeout(0)
    local succ, err
    while not succ do
        succ, err = sock:dohandshake()
        -- print(sock:dohandshake())
        -- print("succ", succ, "err", err)
        if err == "wantread" then
            socket.select({ sock }, nil)
        elseif err == "wantwrite" then
            socket.select(nil, { sock })
        elseif not succ then
            error("Error doing handshake: " .. err)
        end
    end
    return sock
end

-- local client = assert(socket.connect(ip, port))
-- if secure then
--     client = encrypConnection(client, "client")
-- end
--
local function connectToServer(lip, lport)
    local out = assert(socket.connect(lip, lport))
    if secure then
        return encrypConnection(out, "client")
    end
    return out
end

-- local function printBinary(data)
--     print(data:gsub("%c", function(c)
--         return string.format("%02X", string.byte(c))
--     end))
-- end
--
local connections = {}
server:settimeout(0)
while true do
    while true do
        local browser, err = server:accept()
        if err == "timeout" then
            break
        elseif err ~= nil then
            error("Error accepting: " .. err)
        end
        table.insert(connections, {
            browser = browser,
            client = connectToServer(ip, port),
        })
    end
    for _, conn in ipairs(connections) do
        local msg = assertNonBlockingRead(conn.browser)
        if msg then
            if hypertext then
                if secure then
                    msg = string.gsub(msg, "http://" .. serverURLName, "https://lua.org")
                end
                msg = string.gsub(msg, serverURLName, "lua.org")
            end
            print("*** Send from bwoser:")
            print(msg)
            assert(conn.client:send(msg))
            print("*** Broser send succesful")
        end
        msg = assertNonBlockingRead(conn.client)
        if msg then
            print("*** Send from wbesie:")
            print(msg:sub(1, 100))
            assert(conn.browser:send(msg))
            print("*** Website send succesful")
        end
    end
end
