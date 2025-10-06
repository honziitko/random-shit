const std = @import("std");

fn counter() fn () u32 {
    return struct {
        var i: u32 = 0;
        pub fn lamba() u32 {
            defer i += 1;
            return i;
        }
    }.lamba;
}

pub fn main() !void {
    const c1 = counter();
    const c2 = counter();
    for (0..10) |_| {
        std.debug.print("c1: {}\n", .{c1()});
    }
    for (0..10) |_| {
        std.debug.print("c2: {}\n", .{c2()});
    }
}
