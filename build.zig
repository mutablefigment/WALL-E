const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // common code library shared between all of the different executlables
    const utils = b.addModule(
        "WALLE-utils",
        .{
            .root_source_file = b.path("src/utils/root.zig"),
            .link_libc = true,
        },
    );

    // Build for the debugging client
    build_debugger(
        b,
        target,
        optimize,
        utils,
    );

    // Build step for the "brain" that runs the processing and LLM
    build_brain(
        b,
        target,
        optimize,
    );

    // Build setp for the controller software
    build_contoller(
        b,
        target,
        optimize,
        utils,
    );
}

fn build_debugger(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    utils: *std.Build.Module,
) void {
    const debugger = b.addExecutable(.{
        .name = "WALLE-debugger",
        .root_source_file = b.path("src/debugger/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    //TODO: build raylib using the builder and link against the executable here!
    debugger.linkSystemLibrary("raylib");
    debugger.root_module.addImport("WALLE-utils", utils);

    b.installArtifact(debugger);

    const run_debugger = b.addRunArtifact(debugger);
    run_debugger.step.dependOn(b.getInstallStep());

    const run_debugger_option = b.step("run-debugger", "Run the debugger");
    run_debugger_option.dependOn(&run_debugger.step);
}

fn build_brain(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    // utils: *std.Build.Module,
) void {
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

fn build_contoller(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    utils: *std.Build.Module,
) void {
    const controller = b.addExecutable(.{
        .name = "WALLE-controller",
        .root_source_file = b.path("src/controller/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    // import shared utils code
    controller.root_module.addImport("WALLE-utils", utils);

    b.installArtifact(controller);

    const run_debugger = b.addRunArtifact(controller);
    run_debugger.step.dependOn(b.getInstallStep());

    const run_debugger_option = b.step("run-controller", "Run the controller");
    run_debugger_option.dependOn(&run_debugger.step);
}
