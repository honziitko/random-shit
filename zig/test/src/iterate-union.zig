const std = @import("std");

const U = union(enum) {
    A: i32,
    B: []const u8,
};

fn handleU(u: U) void {
    const tag = std.meta.activeTag(u);
    const Tag = std.meta.Tag(U);
    inline for (std.meta.fields(U)) |f| {
        if (std.meta.stringToEnum(Tag, f.name) == tag) {
            const value = @field(u, f.name);
            std.debug.print("Tag {} contains: {any}\n", .{ tag, value });
            @call(.auto, std.debug.print, .{ "Tag {} constains: {any}\n", .{ tag, value } });
        }
    }
}

pub fn main() void {
    const stuff = [_]U{
        .{ .A = 1 },
        .{
            .B = "Hi!",
        },
        .{ .A = 2 },
        .{ .A = 3 },
    };
    for (stuff) |x| {
        handleU(x);
    }

    const x: u8 = 1;
    const y: i16 = 2;
    std.debug.print("{s}\n", .{@typeName(@TypeOf(x, y))});
}
