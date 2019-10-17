import macros

{.passc: "-DWIN32_LEAN_AND_MEAN".}

type
  UINT* = uint32
  WINBOOL* = int32
  BYTE* = uint8
  SHORT* = cshort
  WORD* = uint16
  DWORD* = uint32
  ULONG_PTR* {.importc, noDecl.} = csize
  DWORD_PTR* = ULONG_PTR
  HANDLE* = pointer
  HWND* = HANDLE
  HMENU* = HANDLE
  HINSTANCE* = HANDLE
  HDC* = HANDLE
  HGLRC* = HANDLE
  HWAVEOUT* = HANDLE
  MMRESULT* = UINT

  MSG* {.importc, header: "<Windows.h>".} = object
    message*: UINT
  WAVEFORMATEX* {.importc, header: "<Mmreg.h>".} = object
    wFormatTag*: WORD
    nChannels*: WORD
    nSamplesPerSec*: DWORD
    nAvgBytesPerSec*: DWORD
    nBlockAlign*: WORD
    wBitsPerSample*: WORD
    cbSize*: WORD
  WAVEHDR* {.importc, header: "#include <Windows.h>\n#include <Mmsystem.h>".} = object
    lpData*: cstring
    dwBufferLength*: DWORD
    dwBytesRecorded*: DWORD
    dwUser*: DWORD_PTR
    dwFlags*: DWORD
    dwLoops*: DWORD
    lpNext*: ptr WAVEHDR
    reserved*: DWORD_PTR

  MMTIME_U* {.pure, union.} = object
    ms*: DWORD
    sample*: DWORD
    cb*: DWORD
    ticks*: DWORD

  MMTIME* {.importc, header: "<Mmsystem.h>".} = object
    wType*: UINT
    u*: MMTIME_U

  PIXELFORMATDESCRIPTOR* {.final, pure.} = object
    nSize*: WORD
    nVersion*: WORD
    dwFlags*: DWORD
    iPixelType*: BYTE
    cColorBits*: BYTE
    cRedBits*: BYTE
    cRedShift*: BYTE
    cGreenBits*: BYTE
    cGreenShift*: BYTE
    cBlueBits*: BYTE
    cBlueShift*: BYTE
    cAlphaBits*: BYTE
    cAlphaShift*: BYTE
    cAccumBits*: BYTE
    cAccumRedBits*: BYTE
    cAccumGreenBits*: BYTE
    cAccumBlueBits*: BYTE
    cAccumAlphaBits*: BYTE
    cDepthBits*: BYTE
    cStencilBits*: BYTE
    cAuxBuffers*: BYTE
    iLayerType*: BYTE
    bReserved*: BYTE
    dwLayerMask*: DWORD
    dwVisibleMask*: DWORD
    dwDamageMask*: DWORD

const
  # pixel types
  PFD_TYPE_RGBA* = 0
  PFD_TYPE_COLORINDEX* = 1

  # layer types
  PFD_MAIN_PLANE* = 0
  PFD_OVERLAY_PLANE* = 1
  PFD_UNDERLAY_PLANE* = -1

  # PIXELFORMATDESCRIPTOR flags
  PFD_DOUBLEBUFFER* = 0x00000001'u32
  PFD_STEREO* = 0x00000002'u32
  PFD_DRAW_TO_WINDOW* = 0x00000004'u32
  PFD_DRAW_TO_BITMAP* = 0x00000008'u32
  PFD_SUPPORT_GDI* = 0x00000010'u32
  PFD_SUPPORT_OPENGL* = 0x00000020'u32
  PFD_GENERIC_FORMAT* = 0x00000040'u32
  PFD_NEED_PALETTE* = 0x00000080'u32
  PFD_NEED_SYSTEM_PALETTE* = 0x00000100'u32
  PFD_SWAP_EXCHANGE* = 0x00000200'u32
  PFD_SWAP_COPY* = 0x00000400'u32
  PFD_SWAP_LAYER_BUFFERS* = 0x00000800'u32
  PFD_GENERIC_ACCELERATED* = 0x00001000'u32
  PFD_SUPPORT_DIRECTDRAW* = 0x00002000'u32
  PFD_DIRECT3D_ACCELERATED* = 0x00004000'u32
  PFD_SUPPORT_COMPOSITION* = 0x00008000'u32

  # PIXELFORMATDESCRIPTOR flags for use in ChoosePixelFormat only
  PFD_DEPTH_DONTCARE* = 0x20000000'u32
  PFD_DOUBLEBUFFER_DONTCARE* = 0x40000000'u32
  PFD_STEREO_DONTCARE* = 0x80000000'u32

  WS_POPUP* = 0x80000000'u32
  WS_VISIBLE* = 0x10000000'u32

  PM_REMOVE* = 0x0001'u32
  VK_ESCAPE* = 0x1B'i32

  WAVE_FORMAT_PCM* = 1'u16
  WAVE_FORMAT_IEEE_FLOAT* = 0x0003'u16

  WAVE_MAPPER* = UINT.high.UINT
  CALLBACK_WINDOW* = 0x00010000'u32

  MMSYSERR_NOERROR* = 0'u32
  MAXERRORLENGTH* = 256
  MM_WOM_DONE* = 0x3BD'u32

  # types for wType field in MMTIME struct
  TIME_MS* = 0x0001'u32  # time in milliseconds
  TIME_SAMPLES* = 0x0002'u32  # number of wave samples
  TIME_BYTES* = 0x0004'u32  # current byte offset
  TIME_SMPTE* = 0x0008'u32  # SMPTE time
  TIME_MIDI* = 0x0010'u32  # MIDI time
  TIME_TICKS* = 0x0020'u32  # Ticks within MIDI stream

macro importAPI(header: string; stmts: untyped): untyped =
  stmts.expectKind nnkStmtList
  result = newStmtList()

  let headerFull = "<" & header.strVal & ">"
  for child in stmts.children:
    if child.kind == nnkCommentStmt:
      continue

    child.expectKind nnkProcDef

    var prc = copy child
    prc.pragma = add(newNimNode(nnkPragma),
                     ident"stdcall",
                     ident"importc",
                     add(newNimNode(nnkExprColonExpr),
                         ident"header",
                         newLit(headerFull)))
    result.add(prc)

importAPI("Windows.h"):
  proc MessageBoxA*(hWnd:HWND, lpText: cstring, lpCaption: cstring, uType: UINT): int32
  proc CreateWindowExA*(
       dwExStyle: DWORD,
       lpClassName: cstring,
       lpWindowName: cstring,
       dwStyle: DWORD,
       X: cint,
       Y: cint,
       nWidth: cint,
       nHeight: cint,
       hWndParent: HWND,
       hMenu: HMENU,
       hInstance: HINSTANCE,
       lpParam: pointer
  ): HWND
  proc GetDC*(
       hWnd: HWND
  ): HDC
  proc PeekMessageA*(
       lpMsg: ptr MSG,
       hWnd: HWND,
       wMsgFilterMin: UINT,
       wMsgFilterMax: UINT,
       wRemoveMsg:UINT
  ): WINBOOL
  proc ExitProcess*(
       uExitCode: UINT
  )
  proc GetAsyncKeyState*(
       vKey: cint
  ): SHORT
  proc Sleep*(
    dwMilliseconds: DWORD
  )
  proc waveOutOpen*(
       phwo: ptr HWAVEOUT,
       uDeviceID: UINT,
       pwfx: ptr WAVEFORMATEX,
       dwCallback: DWORD_PTR,
       dwInstance: DWORD_PTR,
       fdwOpen: DWORD
  ): MMRESULT
  proc waveOutPrepareHeader*(
       hwo: HWAVEOUT,
       pwh: ptr WAVEHDR,
       cbwh: UINT
  ): MMRESULT
  proc waveOutWrite*(
       hwo: HWAVEOUT,
       pwh: ptr WAVEHDR,
       cbwh: UINT
  ): MMRESULT
  proc waveOutGetErrorTextW*(
       mmrError: MMRESULT,
       pszText: ptr Utf16Char,
       cchText: UINT
  ): MMRESULT
  proc waveOutGetPosition*(
       hwo: HWAVEOUT,
       pmmt: ptr MMTIME,
       cbmmt: UINT
  ): MMRESULT

template CreateWindowA*(
         lpClassName, lpWindowName, dwStyle, x, y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam: typed): HWND =
  CreateWindowExA(0'u32, lpClassName, lpWindowName, dwStyle, x, y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam)

importAPI("wingdi.h"):
  proc ChoosePixelFormat*(
       hdc: HDC,
       ppfd: ptr PIXELFORMATDESCRIPTOR
  ): cint
  proc SetPixelFormat*(
       hdc: HDC,
       format: cint,
       ppfd: ptr PIXELFORMATDESCRIPTOR
  ): WINBOOL
  proc SwapBuffers*(
    Arg1: HDC
    ): WINBOOL
  proc wglCreateContext*(
       Arg1: HDC
  ): HGLRC
  proc wglMakeCurrent*(
       arg1: HDC,
       arg2: HGLRC
  ): WINBOOL
  proc wglGetProcAddress*(
       Arg1: cstring
  ): pointer
