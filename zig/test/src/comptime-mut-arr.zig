const std = @import("std");

pub fn main() !void {
    const s = comptime comptimeMap("ABC");
    @compileLog(s);
}

fn comptimeMap(comptime s: []const u8) [s.len]u8 {
    comptime var out: [s.len]u8 = undefined;
    inline for (s, 0..) |c, i| {
        out[i] = c + 1;
    }
    return out;
}
