const std = @import("std");
const utils = @import("WALLE-utils");

pub fn main() !void {
    std.log.debug("hello, world", .{});

    var stream = try utils.VidoeClient.connect_to_server("127.0.0.1", 5555);
    defer stream.close();

    _ = try stream.write("test");
}
