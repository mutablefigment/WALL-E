const std = @import("std");
const zmq = @import("zzmq");
const testing = std.testing;

/// ZMQ Server for receiving incoming data streams
/// from clients over PUB/SUB sockets.
/// In this case the data should be either raw video frames.
pub const CommServer = struct {
    alloc_: std.mem.Allocator,
    socket_map: ?[]zmq.ZSocket,
    data_callback: ?*const fn (data: []const u8) void,

    pub fn init(allocator: std.mem.Allocator) !CommServer {
        return .{
            .alloc_ = allocator,
            .socket_map = null,
            .data_callback = null,
        };
    }

    pub fn register_callback(self: *CommServer, callback: *const fn (data: []const u8) void) void {
        self.data_callback = callback;
    }

    pub fn run(self: *CommServer) !void {
        const callback = self.data_callback orelse @panic("No callback setup, call register_callback before run!");

        while (true) {
            {
                // receive a dataframe
                const map = self.socket_map.?;
                var socket = map[0];
                var frame = try socket.receive(.{});
                defer frame.deinit();

                const data_payload = try frame.data();
                callback(data_payload);
            }
        }
    }

    // pub fn deinit(self: *CommServer) void {
    //     self.alloc_.free(self.socket_map);
    // }
};
