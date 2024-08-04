const avif = @import("avif.zig");
const network = @import("networking.zig");

// Public exports of the module
pub const AVIFReader = avif.AvifStreamReader;

// Networking code
pub const VideoServer = network.VideoServer;
pub const VidoeClient = network.VideoClient;
