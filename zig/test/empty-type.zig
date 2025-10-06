const std = @import("std");

const S = struct {};

export fn bogus_amogus_function() void {
    const x: [16]S = undefined;
    std.debug.print("{}\n", .{x[2]});
}

pub fn main() void {
    const x: [16]S = undefined;
    std.debug.print("@sizeOf(S) = {}, @sizeOf(@TypeOf(x)) = {}\n", .{ @sizeOf(S), @sizeOf(@TypeOf(x)) });
    for (x) |xprime| {
        std.debug.print("{}\n", .{xprime});
    }
    std.debug.print("@sizeOf(?S) = {}\n", .{@sizeOf(?S)});
    const p: *allowzero S = @ptrFromInt(0);
    std.debug.print("{}\n", .{p.*});
}
