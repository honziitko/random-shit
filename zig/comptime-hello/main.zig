pub fn main() !void {
    const s = @embedFile("stdin");
    @compileError("Why, hello there, " ++ s);
}
