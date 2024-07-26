const std = @import("std");
const zmq = @import("zzmq");
const testing = std.testing;

/// Max number of sockets the server can accept
pub const MAX_SOCKET = 10;

/// ZMQ Server for receiving incoming data streams
/// from clients over PUB/SUB sockets.
/// In this case the data should be either raw video frames.
pub const CommServer = struct {
    alloc_: std.mem.Allocator,
    socket_map: []zmq.ZSocket,
    data_callback: ?*const fn (data: []const u8) void,
    socket_count: u32,

    pub fn init(allocator: std.mem.Allocator) !CommServer {
        return .{
            .alloc_ = allocator,
            .socket_map = allocator.alloc(zmq.ZSocket, MAX_SOCKET) catch unreachable,
            .data_callback = null,
            .socket_count = 0,
        };
    }

    pub fn register_callback(self: *CommServer, callback: *const fn (data: []const u8) void) void {
        self.data_callback = callback;
    }

    pub fn add_socket(self: *CommServer, socket: *zmq.ZSocket) !void {
        self.socket_map[self.socket_count] = socket.*;
        self.socket_count += 1;
    }

    pub fn run(self: *CommServer) !void {
        const callback = self.data_callback orelse @panic("No callback setup, call register_callback before run!");
        const map = self.socket_map;

        while (true) {
            {
                // receive a dataframe
                var socket = map[self.socket_count];
                var frame = try socket.receive(.{});
                defer frame.deinit();

                const data_payload = try frame.data();
                callback(data_payload);
            }
        }
    }

    pub fn deinit(self: *CommServer) void {
        self.alloc_.free(self.socket_map);
    }
};
