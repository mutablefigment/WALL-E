const std = @import("std");
const zzmq = @import("zzmq");

const lib = @import("server.zig");

fn data_callback(data: []const u8) void {
    std.log.debug("Got data: {any}", .{data});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        if (gpa.deinit() == .leak)
            @panic("Memory leaked");
    }
    const allocator = gpa.allocator();
    var context = try zzmq.ZContext.init(allocator);
    defer context.deinit();

    var socket = try zzmq.ZSocket.init(zzmq.ZSocketType.Sub, &context);
    defer socket.deinit();
    try socket.bind("tcp://127.0.0.1:5555");

    // open the file
    const path = "./data.mp4";

    var data_buffer: [std.fs.max_path_bytes]u8 = undefined;
    // try allocator.alloc(u8, std.fs.max_path_bytes);

    const full_path = try std.fs.realpath(path, &data_buffer);

    const file = std.fs.openFileAbsolute(full_path, .{ .mode = .read_only }) catch |err| {
        std.log.err("Failed to open file {s}", .{full_path});
        return err;
    };
    defer file.close();

    const databuffer: []u8 = undefined;
    const video_size = try file.readAll(databuffer);
    std.log.info("Read {d} of bytes", .{video_size});

    _ = try zzmq.ZMessage.initUnmanaged(databuffer, allocator);

    // open pipe
    var server = try lib.CommServer.init(allocator);
    // defer server.deinit();

    server.register_callback(&data_callback);
    try server.run();

    // Can we send video to a pipe > on the other end of the pipe ffmpeg is running.
    // - the most important thing rn is getting the video from the client to the server!

}
