MEMORY
{
  BOOT2 : ORIGIN = 0x010000000, LENGTH = 0x100
  FLASH : ORIGIN = 0x010000100, LENGTH = 2048K - 0x100
  RAM   : ORIGIN = 0x020000000, LENGTH = 264K
}

SECTIONS
{
  .boot2 ORIGIN(BOOT2) :
  {
    KEEP(*(.boot2));
  } > FLASH
}
