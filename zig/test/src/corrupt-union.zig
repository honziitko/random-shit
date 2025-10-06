const std = @import("std");

const MyUnion = union(enum) {
    Int: i32,
    String: []const u8,
    Dummy: [4]i64,
};

var devUrandom: ?std.fs.File = null;
fn getGarbageU() !MyUnion {
    if (devUrandom == null) {
        devUrandom = try std.fs.cwd().openFile("/dev/urandom", .{});
    }
    var out: MyUnion = undefined;
    const n = devUrandom.?.read(std.mem.asBytes(&out)) catch unreachable;
    std.debug.assert(n == @sizeOf(MyUnion));
    return out;
}

fn getCorruptU() !MyUnion {
    while (true) {
        const u = try getGarbageU();
        const tag = std.meta.activeTag(u);
        if (tag != .Int and tag != .String and tag != .Dummy) {
            return u;
        }
    }
}

fn isCorrupt(u: anytype) bool {
    const U = @TypeOf(u);
    const getTag = std.meta.activeTag;
    switch (@typeInfo(U)) {
        .Union => {
            inline for (std.meta.fields(U)) |f| {
                const tag = std.meta.stringToEnum(std.meta.Tag(U), f.name).?;
                if (getTag(u) == tag) {
                    return false;
                }
            }
            return true;
        },
        else => @compileError(std.fmt.comptimePrint("Expected a union, found `{s}`", .{@typeName(U)})),
    }
}

pub fn main() !void {
    const corruptU = try getCorruptU();
    const us = [_]MyUnion{ .{ .Int = 1 }, .{ .String = "hi" }, .{ .Dummy = .{ 1, 2, 3, 4 } }, corruptU };
    for (us) |u| {
        if (isCorrupt(u)) {
            std.debug.print("Corrupt\n", .{});
            continue;
        }
        switch (u) {
            .Int => |i| std.debug.print("i32({})\n", .{i}),
            .String => |s| std.debug.print("str({s})\n", .{s}),
            .Dummy => std.debug.print("dummy\n", .{}),
        }
    }
}
