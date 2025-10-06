const std = @import("std");

fn foo() !void {
    return error.UhOh;
}

pub fn main() !void {
    const thread = try std.Thread.spawn(.{}, foo, .{});
    thread.join();
    std.debug.print("Print something pls :3\n", .{});
}
