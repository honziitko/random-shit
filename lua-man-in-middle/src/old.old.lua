local socket = require("socket")
local argparse = require("argparse")

local parser = argparse()
parser:argument("ip", "IP to connect to or if -h specified, the website name")
parser:argument("port", "Port to connect to. Use 80 for HTTP and 443 for HTTPS")
parser:flag("-H --hypertext", "Connect to a website rather than raw dawging some TCP")
parser:flag("-s --secure", "Enctrypt traffic from self to server")

local args = parser:parse()

local ip = args.ip
local port = assert(tonumber(args.port))
local hypertext = args.hypertext or false
local secure = args.secure or false

if #arg < 2 then
    print(string.format("Usage: %s <ip> <port>", arg[0]))
    return
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
print(serverURLName)

local function nonBlockingRead(sock)
    sock:settimeout(0)
    local acc = nil
    while true do
        local data, err = sock:receive(1)
        if err ~= nil then
            if err == "timeout" then
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
        error(string.format("Error reveiving %s: %s", stringifySocket(sock), err))
    end
    return data
end

local browser = server:accept()
local client = assert(socket.connect(ip, port))
while true do
    local msg = assertNonBlockingRead(browser)
    if msg then
        if hypertext then
            msg = string.gsub(msg, serverURLName, "lua.org")
        end
        client:send(msg)
        print("Sent from browser:", msg:sub(1, 100))
    end
    msg = assertNonBlockingRead(client)
    if msg then
        browser:send(msg)
        print("Sent from wbesie:", msg:sub(1, 100))
    end
end
