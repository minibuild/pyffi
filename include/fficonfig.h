#if defined(_WIN32)
#  if defined(_WIN64)
#    if defined(_MSC_VER)
#      include <fficonfig_msvc.h>
#    else
#      include <fficonfig_mingw64.h>
#    endif
#  else
#    if defined(_MSC_VER)
#      include <fficonfig_msvc.h>
#    else
#      include <fficonfig_mingw32.h>
#    endif
#  endif
#elif defined(__linux__)
#  if defined(__x86_64__)
#    include <fficonfig_linux_x86_64.h>
#  elif defined(__i386__)
#    include <fficonfig_linux_i686.h>
#  elif defined(__aarch64__)
#    include <fficonfig_linux_aarch64.h>
#  elif defined(__arm__)
#    include <fficonfig_linux_arm.h>
#  else
#    error "Unknown linux arch."
#  endif
#elif defined(__APPLE__)
#    include <fficonfig_macosx.h>
#else
#  error "Unknown platform."
#endif
