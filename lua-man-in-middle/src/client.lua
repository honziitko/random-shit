local socket = require("socket")

local client = socket.connect("127.0.0.1", 6969)

while true do
    client:settimeout(.1)
    print(client:receive())

    client:send("Hi!")
end
