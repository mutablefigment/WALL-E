const std = @import("std");
const avif = @cImport(
    @cInclude("avif/avif.h"),
);

pub const AvifStreamReader = struct {
    io: avif.avifIO,
    ro_data: avif.avifROData,
    downloaded_bytes: c_int,
    allocator: *const std.mem.Allocator,

    pub fn init(allocator: *const std.mem.Allocator) AvifStreamReader {
        return .{
            .io = .{},
            .ro_data = .{},
            .downloaded_bytes = 0,
            .allocator = allocator,
        };
    }

    pub fn read(self: *const AvifStreamReader) avif.avifROData {
        var out: avif.avifROData = .{};

        const offset = 0;
        out.data = self.ro_data.data + offset;
        out.size = 1;
        return out;
    }
};
