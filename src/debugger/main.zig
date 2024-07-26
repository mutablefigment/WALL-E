const std = @import("std");

const raylib = @cImport(
    @cInclude("raylib.h"),
);

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

    const icon = raylib.LoadImage("icon.svg");
    defer raylib.UnloadImage(icon);

    const icon_texture = raylib.LoadTextureFromImage(icon);
    defer raylib.UnloadTexture(icon_texture);

    // load better font
    const font = raylib.LoadFont("0xProtoNerdFont-Regular.ttf");
    defer raylib.UnloadFont(font);

    raylib.SetTargetFPS(60);
    // FIXME: we cannot set an icon on wayland?
    raylib.SetWindowIcon(icon);

    while (true) {
        raylib.BeginDrawing();
        {
            raylib.ClearBackground(raylib.BLACK);
            // raylib.DrawRectangle(10, 10, 250, 250, raylib.WHITE);

            // HEADER
            {
                raylib.DrawTexture(icon_texture, 0, 0, raylib.WHITE);

                const pos = raylib.Vector2{ .x = 50, .y = 15 };
                raylib.DrawTextEx(
                    font,
                    TITLE,
                    pos,
                    16,
                    1,
                    raylib.YELLOW,
                );
            }

            // VIDEO FEED?
            {}
        }
        raylib.EndDrawing();
    }
}
