const std = @import("std");
const sys = std.os.linux;

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer {
    //     if (gpa.deinit() == .leak) {
    //         @panic("Memory leaked");
    //     }
    // }
    // const allocator = gpa.allocator();

    // const addr = try std.net.Address.parseIp("127.0.0.1", 55555);
    // const socket = sys.socket(sys.AF.INET, sys.SOCK.DGRAM, sys.IPPROTO.UDP);
    // defer sys.close(socket);

    // // bind socket
    // try sys.bind(socket, &addr, addr.getOsSockLen());
    // var buf: [1024]u8 = undefined;
    // const len = try sys.recvmsg(socket, &buf, 0);
    // std.debug.print("{s}\r", .{buf[0..len]});
}
