import macros

{.passc: "-DWIN32_LEAN_AND_MEAN".}

type
  UINT* = uint32
  WINBOOL* = int32
  BYTE* = uint8
  SHORT* = cshort
  WORD* = uint16
  DWORD* = uint32
  HANDLE* = pointer
  HWND* = HANDLE
  HMENU* = HANDLE
  HINSTANCE* = HANDLE
  HDC* = HANDLE
  HGLRC* = HANDLE

  MSG* {.importc, header: "<Windows.h>".} = object

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
