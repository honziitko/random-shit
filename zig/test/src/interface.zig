const std = @import("std");

fn checkMethod(T: type, I: type, comptime name: []const u8) bool {
    const TDecl = @TypeOf(@field(T, name));
    const IDecl = @TypeOf(@field(I, name));
    // const tInfo = @typeInfo(TDecl);
    // const iInfo = @typeInfo(IDecl);
    return TDecl == IDecl;
}

fn implements(T: type, I: type) bool {
    inline for (std.meta.fields(I)) |f| {
        if (!@hasField(T, f.name)) {
            return false;
        }
        const t: T = undefined;
        if (@TypeOf(@field(t, f.name)) != f.type) {
            return false;
        }
    }
    inline for (std.meta.declarations(I)) |decl| {
        if (!@hasDecl(T, decl.name)) {
            return false;
        }
        if (!checkMethod(T, I, decl.name)) {
            return false;
        }
    }
    return true;
}

pub fn main() !void {
    const Animal = struct {
        pub fn makeSound() void {
            std.debug.print("Unspecified animal sound\n", .{});
        }
        pub fn foo(self: @This()) void {
            std.debug.print("{}\n", .{self.x});
        }
        x: i32,
    };

    const Dog = struct {
        pub fn makeSound() void {
            std.debug.print("Bark\n", .{});
        }
        pub fn foo(self: @This()) void {
            std.debug.print("{}\n", .{self.x});
        }
        // const foo = 5;
        x: i32,
    };

    // tezt(@hasDecl(Dog, "makeSound"));
    inline for (std.meta.fields(Animal)) |f| {
        std.debug.print("f animal {}\n", .{f});
    }
    inline for (@typeInfo(Animal).Struct.decls) |decl| {
        std.debug.print("decl animal {}\n", .{decl});
    }
    inline for (std.meta.fields(Dog)) |f| {
        std.debug.print("f dog {}\n", .{f});
    }
    inline for (@typeInfo(Dog).Struct.decls) |decl| {
        std.debug.print("decl dog {}\n", .{decl});
    }
    tezt(implements(Dog, Animal));
}

fn tezt(comptime x: bool) void {
    @compileError(comptimeStringify(x));
}

fn comptimeStringify(comptime x: anytype) []const u8 {
    return std.fmt.comptimePrint("{}", .{x});
}
