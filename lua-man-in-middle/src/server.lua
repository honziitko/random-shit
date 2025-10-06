local socket = require("socket")

local server = assert(socket.bind("127.0.0.1", 0))

local ip, port = server:getsockname()
print(ip, port)

local nonBlockingTimeout = .1
local function nonBlockingRead(sock)
    sock:settimeout(nonBlockingTimeout)
    local data, err = sock:receive()
    if err ~= nil then
        if err == "timeout" then
            return nil, nil
        end
        return nil, err
    end
    return data, nil
end

local client = server:accept()
while true do
    print(nonBlockingRead(client))

    client:send("Hi!\n")
end
