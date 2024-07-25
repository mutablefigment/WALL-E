const std = @import("std");
const zmq = @import("zzmq");
const testing = std.testing;

/// ZMQ Server for receiving incoming data streams
/// from clients over PUB/SUB sockets.
/// In this case the data should be either raw video frames.
pub const CommServer = struct {
    alloc_: std.mem.Allocator,
    socket_map: []zmq.ZSocket,
    data_callback: *const fn (data: []u8) void,

    pub fn init(allocator: *std.mem.Allocator) !CommServer {
        return .{
            .alloc_ = allocator,
        };
    }

    pub fn register_callback(self: *CommServer, callback: *const fn (data: []u8) void) void {
        self.data_callback = callback;
    }

    pub fn run(self: *CommServer) void {
        while (true) {
            {
                // receive a dataframe
                var frame = try self.socket_map[0].receive(.{});
                defer frame.deinit();

                const data_payload = try frame.data();
                self.data_callback(data_payload);
            }
        }
    }

    pub fn deinit(self: *CommServer) void {
        self.alloc_.free(self.socket_map);
    }
};
