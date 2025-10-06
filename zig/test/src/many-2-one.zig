const std = @import("std");

fn typeOfMember(comptime T: type, comptime field: []const u8) type {
    const x: T = undefined;
    return @TypeOf(@field(x, field));
}

fn ManyTwoOneMap(comptime K: type, comptime V: type, comptime Context: type) type {
    return struct {
        const Self = @This();
        const Entry = struct { key: K, value: V };
        const List = std.ArrayList(Entry);
        const Error = error{SemiAlreadyExists};
        list: List,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{ .list = List.init(allocator) };
        }

        pub fn iterable(self: Self) []Entry {
            return self.list.items;
        }

        pub fn find(self: Self, comptime category: []const u8, key: typeOfMember(K, category)) ?*Entry {
            const cmp = @field(Context, category);
            for (self.list.items) |*entry| {
                if (cmp(@field(entry.key, category), key)) {
                    return entry;
                }
            }
            return null;
        }

        pub fn get(self: Self, comptime category: []const u8, key: typeOfMember(K, category)) ?V {
            return (self.find(category, key) orelse return null).value;
        }

        pub fn contains(self: Self, comptime category: []const u8, key: typeOfMember(K, category)) bool {
            return self.find(category, key) != null;
        }

        pub fn put(self: *Self, key: K, value: V) !void {
            const fields = std.meta.fields(K);
            const fieldName = fields[0].name;
            const expected = self.find(fieldName, @field(key, fieldName));
            inline for (1..fields.len) |i| {
                if (self.find(fields[i].name, @field(key, fields[i].name)) != expected) {
                    return Error.SemiAlreadyExists;
                }
            }
            if (expected) |entry| {
                entry.value = value;
            } else {
                try self.list.append(.{ .key = key, .value = value });
            }
        }
    };
}

const S = struct {
    x: i32,
    y: i32,
};

const Ctx = struct {
    fn x(lhs: i32, rhs: i32) bool {
        return lhs == rhs;
    }
    fn y(lhs: i32, rhs: i32) bool {
        return lhs == rhs;
    }
};
fn vec(x: i32, y: i32) S {
    return .{ .x = x, .y = y };
}

const Map = ManyTwoOneMap(S, []const u8, Ctx);
fn lookup(map: Map, comptime category: []const u8, key: anytype) void {
    std.debug.print("(.{s} = {}) -> {?s}\n", .{ category, key, map.get(category, key) });
}

pub fn main() !void {
    var map = Map.init(std.heap.page_allocator);
    try map.put(vec(0, 0), "Zero, zero");
    try map.put(vec(1, 2), "One, Two");
    try map.put(vec(3, 4), "Three, Four");
    try map.put(vec(2, 1), "dos uno skull emoji");
    try map.put(vec(0, 0), "Nvm worthless");
    // try map.put(vec(5, 1), "Five, One");

    for (map.iterable()) |entry| {
        std.debug.print("{} -> {s}\n", .{ entry.key, entry.value });
    }
    for (0..5) |i_| {
        const i: i32 = @intCast(i_);
        lookup(map, "x", i);
        lookup(map, "y", i);
    }
}
