usingnamespace @import("cortex_m_startup");

/// The second stage bootloader.
///
/// This embedded as a binary file and placed at the start of flash by the
/// linker script.
///
/// Note: This bootloader is licensed by Raspberry Pi (Trading) Ltd. under the
/// terms of the 3-clause BSD license.
export const _BOOT2: [256]u8 linksection(".boot2") = @embedFile("bin/boot2.bin").*;

extern fn _defaultHandler() callconv(.C) noreturn;

/// Device specific interrupts for the Raspberry Pi Pico.
export const _INTERRUPTS linksection(".vector_table.interrupts") = [_]*const fn () callconv(.C) void{
    // todo: user configurable
    _defaultHandler,
} ** 101;
