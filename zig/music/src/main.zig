const std = @import("std");

const Tone = enum(i32) {
    C = 0,
    CSharp = 1,
    D = 2,
    DSharp = 3,
    E = 4,
    F = 5,
    FSharp = 6,
    G = 7,
    GSharp = 8,
    A = 9,
    ASharp = 10,
    B = 11,
};

const Hz = f32;
const Seconds = f32;

fn arsd(t: f32) f32 {
    return if (t <= 0.2) 5 * t else if (t <= 0.4) 1.4 - 2 * t else if (t <= 0.8) 0.6 else 3 - 3 * t;
}

const Note = struct {
    const twelfethRoot2 = std.math.pow(Hz, 2, 0.0833333333333333333333);
    const baseFreq = 440; //at A_4
    const baseOctave = 4;
    const volume = 0.6;
    const sampleRate = 44100;

    tone: Tone,
    octave: i32,
    pub fn freq(self: Note) Hz {
        const toneAsInt = @intFromEnum(self.tone) - @intFromEnum(Tone.A);
        const octaveOffsetTo4 = self.octave - baseOctave;
        const halfStepsToA4 = octaveOffsetTo4 * 12 + toneAsInt;
        return baseFreq * std.math.pow(Hz, twelfethRoot2, @floatFromInt(halfStepsToA4));
    }

    // pub fn fromTone(tone: Tone) Note {
    //     return Note{
    //         .tone = tone,
    //         .octave = baseOctave,
    //     };
    // }

    pub fn writeToFile(self: Note, duration: Seconds, writer: anytype) !void {
        const step = (self.freq() * std.math.tau) / sampleRate;
        var i: usize = 0;
        const N: usize = @intFromFloat(sampleRate * duration);
        while (i < N) {
            const wave = @sin(step * @as(f32, @floatFromInt(i))) * volume * arsd(@as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(N)));
            _ = try writer.write(@as([*]const u8, @ptrCast(&wave))[0..@sizeOf(f32)]);
            i += 1;
        }
    }
};

const Beats = f32;
const BPM = u32;
const Beat = struct {
    // const bpm = 120;
    // const beatDuration = 60.0 / @as(comptime_float, @floatFromInt(bpm));

    note: Note,
    beats: Beats,

    // pub fn toMS(self: Beat) Ms {
    //     return @intFromFloat(1000 * beatDuration * self.duration);
    // }

    pub fn duration(self: Beat, bpm: BPM) Seconds {
        const beatDuration = 60 / @as(Beats, @floatFromInt(bpm));
        return beatDuration * self.beats;
    }

    pub fn writeToFile(self: Beat, bpm: BPM, writer: anytype) !void {
        try self.note.writeToFile(self.duration(bpm), writer);
    }
};

const Song = struct {
    bpm: BPM,
    beats: []const Beat,

    pub fn writeToFile(self: Song, writer: anytype) !void {
        for (self.beats) |beat| {
            try beat.writeToFile(self.bpm, writer);
        }
    }
};

const daRudeSandstorm = Song{ .bpm = 120, .beats = &[_]Beat{
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.5 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.5 },
    .{ .note = .{ .tone = .D, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .D, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .D, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .D, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .D, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .D, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .D, .octave = 5 }, .beats = 0.5 },
    .{ .note = .{ .tone = .C, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .C, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .C, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .C, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .C, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .C, .octave = 5 }, .beats = 0.25 },
    .{ .note = .{ .tone = .C, .octave = 5 }, .beats = 0.5 },
    .{ .note = .{ .tone = .G, .octave = 4 }, .beats = 0.5 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.25 },
    .{ .note = .{ .tone = .A, .octave = 4 }, .beats = 0.5 },
} };

const songOfStorms = Song{ .bpm = 120, .beats = &[_]Beat{
    .{ .note = .{ .tone = .D, .octave = 5 }, .beats = 0.5 },
    .{ .note = .{ .tone = .F, .octave = 5 }, .beats = 0.5 },
    .{ .note = .{ .tone = .D, .octave = 6 }, .beats = 0.5 },
} };

pub fn main() !void {
    const song = songOfStorms;
    // const file = try std.fs.cwd().createFile("song.pcm", .{});
    // for (song) |beat| {
    //     try beat.writeToFile(file.writer());
    // }
    // defer file.close();

    var child = std.ChildProcess.init(&[_][]const u8{ "ffmpeg", "-y", "-f", "f32le", "-ar", "44100", "-ac", "1", "-i", "pipe:", "song.wav" }, std.heap.page_allocator);

    child.stdin_behavior = .Pipe;
    try child.spawn();

    try song.writeToFile(child.stdin.?);
    child.stdin.?.close();
    child.stdin = null;

    _ = try child.wait();
}

fn testNote(freq: Hz, tone: Tone, ocatave: i32) !void {
    const note = Note{ .tone = tone, .octave = ocatave };
    try std.testing.expectApproxEqRel(freq, note.freq(), comptime std.math.sqrt(std.math.floatEps(Hz)));
}

test "A_4" {
    try testNote(440, .A, 4);
}
test "G_4" {
    try testNote(392, .G, 4);
}

test "G_1" {
    try testNote(49, .G, 1);
}
test "A_1" {
    try testNote(55, .A, 1);
}
test "G_2" {
    try testNote(98, .G, 2);
}

test "A_5" {
    try testNote(880, .A, 5);
}
test "A_7" {
    try testNote(3520, .A, 7);
}
test "A_8" {
    try testNote(7040, .A, 8);
}
