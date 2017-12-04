module_type = 'lib-static'
module_name = 'pyffi_static'

include_dir_list = ['include']
asm_include_dir_list = ['include']

if BUILDSYS_TOOLSET_NAME == 'msvs':
    src_search_dir_list_windows_x86    = ['src/msvc']
    asm_search_dir_list_windows_x86    = ['src/msvc']
    src_search_dir_list_windows_x86_64 = ['src/msvc']
    asm_search_dir_list_windows_x86_64 = ['src/msvc']
else:
    src_search_dir_list_windows_x86    = ['src/vendor', 'src/vendor/x86']
    asm_search_dir_list_windows_x86    = ['src/vendor', 'src/vendor/x86']
    src_search_dir_list_windows_x86_64 = ['src/vendor', 'src/vendor/x86']
    asm_search_dir_list_windows_x86_64 = ['src/vendor', 'src/vendor/x86']

src_search_dir_list_linux_arm      = ['src/vendor', 'src/vendor/arm']
asm_search_dir_list_linux_arm      = ['src/vendor', 'src/vendor/arm']
src_search_dir_list_linux_arm64    = ['src/vendor', 'src/vendor/aarch64']
asm_search_dir_list_linux_arm64    = ['src/vendor', 'src/vendor/aarch64']
src_search_dir_list_linux_x86      = ['src/vendor', 'src/vendor/x86']
asm_search_dir_list_linux_x86      = ['src/vendor', 'src/vendor/x86']
src_search_dir_list_linux_x86_64   = ['src/vendor', 'src/vendor/x86']
asm_search_dir_list_linux_x86_64   = ['src/vendor', 'src/vendor/x86']
src_search_dir_list_macosx         = ['src/macosx']
asm_search_dir_list_macosx         = ['src/macosx']

build_list_linux_x86      = ['prep_cif.c', 'types.c', 'ffi.c', 'sysv.S','win32.S']
build_list_linux_x86_64   = ['prep_cif.c', 'types.c', 'ffi64.c', 'unix64.S']
build_list_linux_arm      = ['prep_cif.c', 'types.c', 'ffi.c', 'sysv.S']
build_list_linux_arm64    = ['prep_cif.c', 'types.c', 'ffi.c', 'sysv.S']
build_list_macosx         = ['types.c', 'ffi.c', 'x86-ffi64.c', 'darwin64.S']
build_list_windows_x86    = ['prep_cif.c', 'types.c', 'ffi.c']
build_list_windows_x86_64 = ['prep_cif.c', 'types.c', 'ffi.c']

if BUILDSYS_TOOLSET_NAME == 'msvs':
    build_list_windows_x86_64 += ['win64.asm']
    build_list_windows_x86    += ['win32.c']
else:
    build_list_windows_x86    += ['win32.S']
    build_list_windows_x86_64 += ['win64.S']
