const std = @import("std");
const Connection = std.net.Server.Connection;

/// A UDP server that listens on a predefined port
/// for incoming connections of a `VideoClient` that
/// send raw video bytes over the network.
/// The client should encode the video data in AV1 format, which
/// the server then decodes as a Stream
pub const VideoServer = struct {
    pub fn bind_server_socket(
        port: u16,
        buffer: *[1024]u8,
    ) !void {
        const address = try std.net.Address.parseIp4("127.0.0.1", port);
        var server = try address.listen(.{
            .reuse_port = true,
        });

        try run(&server, buffer);
    }

    fn run(server: *std.net.Server, buffer: *[1024]u8) !void {
        while (true) {
            const client_socket = try server.accept();
            const client_handler = try std.Thread.spawn(
                .{},
                handle_client,
                .{
                    @as(Connection, client_socket),
                    @as(*[1024]u8, buffer),
                },
            );
            _ = client_handler;
        }
    }

    fn handle_client(client: Connection, buffer: *[1024]u8) !void {
        while (true) {
            const len = try client.stream.read(buffer);
            std.log.debug("read {d} bytes from client", .{len});
            std.log.debug("Got data {s}", .{buffer[0..len]});

            _ = try client.stream.write(buffer);
        }
    }
};

pub const VideoClient = struct {
    pub fn connect_to_server(ip: []const u8, port: u16) !std.net.Stream {
        const address = try std.net.Address.parseIp(ip, port);
        //FIXME: proper error handling if server is not available.
        const client_stream = try std.net.tcpConnectToAddress(address);
        return client_stream;
    }
};
