// The contents of this file is dual-licensed under the MIT or 0BSD license.

const std = @import("std");

const debug = std.debug;

const cortex_m = @import("cortex_m");

const ExecutableOptions = std.Build.ExecutableOptions;
const Step = std.Build.Step;
const Target = std.Target;

/// Compiles the `rpi_pico` project.
///
/// Adds two public modules:
///
/// * `rpi_pico_startup`
/// * `rpi_pico`
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cortex_m_dep = b.dependency("cortex_m", .{
        .target = target,
        .optimize = optimize,
    });

    _ = b.addModule("rpi_pico_startup", .{
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
/// This will automatically link to `rpi_pico_startup` and `rpi_pico`. It will
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

    const rpi_pico_dep = b.dependency("rpi_pico", .{
        .target = options2.target,
        .optimize = options2.optimize,
    });

    executable.addModule(
        "rpi_pico_startup",
        rpi_pico_dep.module("rpi_pico_startup"),
    );

    cortex_m.link(executable, @embedFile("memory.ld")) catch |err| {
        debug.print("failed to link firmware: {}", .{err});
        @panic("");
    };

    return executable;
}
