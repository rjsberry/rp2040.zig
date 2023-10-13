// The contents of this file is dual-licensed under the MIT or 0BSD license.

const std = @import("std");

const debug = std.debug;

const cortex_m = @import("cortex_m");

const ExecutableOptions = std.Build.ExecutableOptions;
const Step = std.Build.Step;
const Target = std.Target;

/// Compiles the `rp2040` project.
///
/// Adds two public modules:
///
/// * `rp2040_startup`
/// * `rp2040`
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cortex_m_dep = b.dependency("cortex_m", .{
        .target = target,
        .optimize = optimize,
    });

    _ = b.addModule("rp2040_startup", .{
        .source_file = .{ .path = "startup/main.zig" },
        .dependencies = &.{
            .{
                .name = "cortex_m_startup",
                .module = cortex_m_dep.module("cortex_m_startup"),
            },
        },
    });
}

/// Adds a new Raspberry Pi Pico firmware executable.
///
/// This will automatically link to `rp2040_startup` and `rp2040`. It will
/// also configure linking the firmware with a precompiled second stage
/// bootloader between `0x010000000` and `0x010000100` in flash.
///
/// The target CPU does not need to be explicitly set in `options`.
pub fn addExecutable(b: *std.Build, options: ExecutableOptions) *Step.Compile {
    var options2 = options;

    options2.target = .{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_model = .{ .explicit = &Target.arm.cpu.cortex_m0plus },
    };

    const executable = b.addExecutable(options2);

    const rp2040_dep = b.dependency("rp2040", .{
        .target = options2.target,
        .optimize = options2.optimize,
    });

    executable.addModule(
        "rp2040_startup",
        rp2040_dep.module("rp2040_startup"),
    );

    cortex_m.link(executable, @embedFile("memory.ld")) catch |err| {
        debug.print("failed to link firmware: {}", .{err});
        @panic("");
    };

    return executable;
}
