const std = @import("std");

pub fn main() !void {
    const net = std.net;

    const serverIp = try net.Address.parseIp("127.0.0.1", 6969);
    var server = try serverIp.listen(.{ .reuse_port = true });
    defer server.deinit();

    std.debug.print("Waiting for connection...\n", .{});
    const client = try server.accept();
    defer client.stream.close();

    while (true) {
        var buf: [1024]u8 = undefined;
        std.debug.print("Waiting for data...\n", .{});
        const n = try client.stream.read(&buf);
        _ = try client.stream.write(buf[0..n]);
    }
}
