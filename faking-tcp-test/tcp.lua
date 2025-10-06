local socket = require("socket")
local server = socket.tcp()
assert(server:bind("127.0.0.1", 6969))
assert(server:listen())

local client = server:accept()
while true do
    client:send(io.read())
end
