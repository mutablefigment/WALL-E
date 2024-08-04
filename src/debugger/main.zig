const std = @import("std");

const raylib = @cImport(
    @cInclude("raylib.h"),
);

const utils = @import("WALLE-utils");

const WIDTH = 800;
const HEIGHT = 600;
const TITLE = "WALL-E Debugger client";

pub fn main() !void {
    raylib.InitWindow(
        WIDTH,
        HEIGHT,
        TITLE,
    );
    defer raylib.CloseWindow();

    const icon = raylib.LoadImage("res/icon.svg");
    defer raylib.UnloadImage(icon);

    const icon_texture = raylib.LoadTextureFromImage(icon);
    defer raylib.UnloadTexture(icon_texture);

    // load better font
    const font = raylib.LoadFont("res/0xProtoNerdFont-Regular.ttf");
    defer raylib.UnloadFont(font);

    raylib.SetTargetFPS(60);
    // FIXME: we cannot set an icon on wayland?
    raylib.SetWindowIcon(icon);
    raylib.SetTextureFilter(font.texture, raylib.TEXTURE_FILTER_POINT);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        if (gpa.deinit() == .leak) {
            @panic("Memory leaked");
        }
    }
    const allocator = gpa.allocator();
    // const streamer: utils.AVIFReader = utils.AVIFReader.init(&allocator);
    // _ = streamer.read();

    var buffer: [1024]u8 = undefined;

    const server_thread = try std.Thread.spawn(
        .{},
        utils.VideoServer.bind_server_socket,
        .{
            @as(u16, 5555),
            @as(*[1024]u8, &buffer),
        },
    );
    _ = server_thread;

    while (true) {
        raylib.BeginDrawing();
        {
            raylib.ClearBackground(raylib.BLACK);
            // raylib.DrawRectangle(10, 10, 250, 250, raylib.WHITE);

            // HEADER
            {
                raylib.DrawTexture(icon_texture, 0, 0, raylib.WHITE);

                const pos = raylib.Vector2{ .x = 50, .y = 12.5 };
                raylib.DrawTextEx(
                    font,
                    TITLE,
                    pos,
                    22.5,
                    0,
                    raylib.YELLOW,
                );

                // show fps counter
                const text = try std.fmt.allocPrintZ(allocator, "{d}", .{raylib.GetFPS()});
                defer allocator.free(text);
                raylib.DrawText(text, 250, 250, 20, raylib.GREEN);
            }

            // VIDEO FEED?
            {
                const text = try std.fmt.allocPrintZ(allocator, "{s}", .{buffer[0..20]});
                defer allocator.free(text);
                raylib.DrawText(text, 10, 300, 28, raylib.PINK);

                // const img: raylib.Image = .{};

                // raylib.LoadImageFromMemory(fileType: [*c]const u8, fileData: [*c]const u8, dataSize: c_int)
                // raylib.LoadTextureFromImage(img);

            }
        }
        raylib.EndDrawing();
    }
}
