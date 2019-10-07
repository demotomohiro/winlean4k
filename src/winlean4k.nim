{.passc: "-DWIN32_LEAN_AND_MEAN".}

type
  HANDLE* = int
  HWND* = HANDLE
  UINT* = uint32

proc MessageBoxA*(hWnd:HWND, lpText: cstring, lpCaption: cstring, uType: UINT): int32 {.
     stdcall, importc, header: "<Windows.h>".}
