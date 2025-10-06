local function numberToBigEndianUshort(x)
    local lowByte = x % 256
    local highByte = (x // 256) % 256
    return string.char(highByte, lowByte)
end

local socket = require("socket")
local messages = require("message")

local sock = socket.udp()
assert(sock:setpeername("127.0.0.1", 6969))

local function wait(secs)
    local start = os.clock()
    while (os.clock() - start) < secs do

    end
end
-- print(numberToBigEndianUshort(tonumber(arg[1])))
local _, clientPort = sock:getsockname()
local clientPortEncoded = numberToBigEndianUshort(clientPort)

local function extractPrintable(s)
    return s:gsub("%c", "")
end

for _, v in ipairs(messages) do
    for i, w in ipairs(v) do
        v[i] = w:gsub("[^%x]", "")
        v[i] = v[i]:gsub("%x%x", function(x)
            return string.char(tonumber("0x" .. x))
        end)
    end
    local message = table.concat(v, clientPortEncoded)
    print("About to send", extractPrintable(message))
    print("Press enter to continue")
    io.read()
    -- print("--------")
    -- print(message)
    -- print("--------")
    sock:send(message)
end
