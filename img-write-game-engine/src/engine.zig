const std = @import("std");

const c = @cImport({
    @cDefine("VC_EXTRALEAN", {});
    @cDefine("WIN32_LEAN_AND_MEAN", {});
    @cInclude("windows.h");
    @cInclude("winuser.h");
    @cInclude("stb_image_write.h");
});

const ClickError = error{ErrorSettingCursor};
fn click() void {
    var input = c.INPUT{ .type = c.INPUT_MOUSE, .unnamed_0 = .{ .mi = .{
        .dx = 0,
        .dy = 0,
        .dwFlags = c.MOUSEEVENTF_LEFTDOWN,
        .time = 0,
    } } };
    _ = c.SendInput(1, @constCast(&input), @sizeOf(c.INPUT));
    input.unnamed_0.mi.dwFlags = c.MOUSEEVENTF_LEFTUP;
    _ = c.SendInput(1, &input, @sizeOf(c.INPUT));
}
fn clickAtPosition(x: c_int, y: c_int) !void {
    if (c.SetCursorPos(x, y) == 0) {
        return ClickError.ErrorSettingCursor;
    }
    click();
}

fn waitForEnter() !void {
    var buf: [1024]u8 = undefined;
    _ = try std.io.getStdIn().reader().readAll(&buf);
}

pub const renderFileName = "frame.png";

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,

    pub fn fromHex(x: u24) Color {
        return Color{
            .r = @intCast((x >> 16) & 0xFF),
            .g = @intCast((x >> 8) & 0xFF),
            .b = @intCast((x >> 0) & 0xFF),
        };
    }
};

fn colorToRGBA(color: Color) u32 {
    const r: u32 = color.r;
    const g: u32 = color.g;
    const b: u32 = color.b;
    // // switch (std.Target.Cpu.Arch.endian()) { //TODO: figure out a way to check for endianess
    // //     .little => return 0xFF000000 | (b << 16) | (g << 8) | (r << 0);
    // //     .big => return r | (g << 8) | (b << 16) | 0x000000FF,
    // // }

    //AABBGGRR (little endian)
    return 0xFF000000 | (b << 16) | (g << 8) | (r << 0);
}

pub const GameState = struct {
    w: usize,
    h: usize,
    data: []u32,
    allocator: std.mem.Allocator,
    refreshButtonPosition: c.POINT,
    ended: bool,

    pub const Error = error{ ImageWriteFailed, CoordinateOutOfRange, GettingCursorPosFailed };

    pub fn deinit(self: *GameState) void {
        self.allocator.free(self.data);
    }

    pub fn clearBackground(self: *GameState, color: Color) void {
        const parsedColor = colorToRGBA(color);
        @memset(self.data, parsedColor);
    }

    pub fn drawRectangle(self: *GameState, x: usize, y: usize, w: usize, h: usize, color: Color) !void {
        if (x + w >= self.w or y + h >= self.h) {
            return error.CoordinateOutOfRange;
        }
        const parsedColor = colorToRGBA(color);
        for (y..y + h) |lineIndex| {
            const lowerIndex = lineIndex * self.w + x;
            const higherIndex = lowerIndex + w;
            @memset(self.data[lowerIndex..higherIndex], parsedColor);
        }
    }

    pub fn renderFrame(self: *GameState) !void {
        if (c.stbi_write_png(renderFileName, @intCast(self.w), @intCast(self.h), 4, self.data.ptr, @intCast(self.w * @sizeOf(u32))) == 0) {
            return error.ImageWriteFailed;
        }
        try clickAtPosition(self.refreshButtonPosition.x, self.refreshButtonPosition.y);
        var pos: c.POINT = undefined;
        _ = c.GetCursorPos(&pos);
        if (pos.x != self.refreshButtonPosition.x or pos.y != self.refreshButtonPosition.y) {
            self.ended = true;
            return;
        }
    }
};

pub fn initGame(w: u32, h: u32, allocator: std.mem.Allocator) !GameState {
    const file = try std.fs.cwd().createFile(renderFileName, .{});
    file.close();
    std.debug.print("Please open the file {s} in your browser.\n", .{renderFileName});
    std.debug.print("After you press Ctrl+Z Enter, a 5 second timer will start.\n", .{});
    std.debug.print("During that time, please put your cursor over the browser's refresh button.\n", .{});
    try waitForEnter();
    {
        var i: u32 = 5;
        while (i > 0) {
            std.debug.print("{}\n", .{i});
            std.time.sleep(1e9);
            i -= 1;
        }
    }
    var cusorPos: c.POINT = undefined;
    if (c.GetCursorPos(&cusorPos) == 0) {
        return error.GettingCursorPosFailed;
    }
    std.debug.print("You are now ready to play the game. Press Ctrl+Z Enter once again to start.\n", .{});
    try waitForEnter();
    return GameState{
        .w = w,
        .h = h,
        .data = try allocator.alloc(u32, w * h),
        .allocator = allocator,
        .refreshButtonPosition = cusorPos,
        .ended = false,
    };
}
