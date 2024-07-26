const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Build for the debugging client
    {
        const debugger = b.addExecutable(.{
            .name = "WALLE-debugger",
            .root_source_file = b.path("src/debugger/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });

        //TODO: build raylib using the builder and link against the executable here!
        debugger.linkSystemLibrary("raylib");
        b.installArtifact(debugger);

        const run_debugger = b.addRunArtifact(debugger);
        run_debugger.step.dependOn(b.getInstallStep());

        const run_debugger_option = b.step("run-debugger", "Run the debugger");
        run_debugger_option.dependOn(&run_debugger.step);
    }

    // Build step for the "brain" that runs the processing and LLM
    {
        const zzmq = b.dependency("zzmq", .{
            .target = target,
            .optimize = optimize,
        });

        const brain = b.addExecutable(.{
            .name = "WALLE-brain",
            .root_source_file = b.path("src/brain/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });

        brain.root_module.addImport("zzmq", zzmq.module("zzmq"));
        brain.linkSystemLibrary("zmq");

        b.installArtifact(brain);

        const run_brain = b.addRunArtifact(brain);
        run_brain.step.dependOn(b.getInstallStep());

        const run_brain_option = b.step("run-brain", "Run the brain server");
        run_brain_option.dependOn(&run_brain.step);
    }

    //TODO: add build steps for the controller software here
    {}
}
