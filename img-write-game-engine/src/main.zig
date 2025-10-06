const std = @import("std");
const engine = @import("engine.zig");
const Color = engine.Color;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    const WIDTH = 800;
    const HEIGHT = 600;
    var gameState = try engine.initGame(WIDTH, HEIGHT, gpa.allocator());
    defer gameState.deinit();

    const DVD_WIDTH = 150;
    const DVD_HEIGHT = 50;
    var dvdX: i32 = WIDTH / 2;
    var dvdY: i32 = HEIGHT / 2;

    const DVD_SPEED = 25;
    var xVelocity: i32 = -DVD_SPEED;
    var yVelocity: i32 = -DVD_SPEED;
    while (!gameState.ended) {
        gameState.clearBackground(Color.fromHex(0x000000));
        try gameState.drawRectangle(@intCast(dvdX), @intCast(dvdY), DVD_WIDTH, DVD_HEIGHT, Color.fromHex(0x00FFFF));
        try gameState.renderFrame();

        dvdX += xVelocity;
        dvdY += yVelocity;
        if (dvdX < 0 or dvdX >= gameState.w - DVD_WIDTH) {
            xVelocity *= -1;
            dvdX += xVelocity;
        }
        if (dvdY < 0 or dvdY >= gameState.h - DVD_HEIGHT) {
            yVelocity *= -1;
            dvdY += yVelocity;
        }
        std.time.sleep(@floor(1e9 / 30e0));
    }
}
