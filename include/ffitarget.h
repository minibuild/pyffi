#if defined(_WIN32)
#  if defined(_MSC_VER) 
#    include <ffitarget_msvc.h>
#  else
#    include <ffitarget_x86.h>
#  endif
#elif defined(__linux__)
#  if defined(__x86_64__) || defined(__i386__)
#    include <ffitarget_x86.h>
#  elif defined(__aarch64__)
#    include <ffitarget_aarch64.h>
#  elif defined(__arm__)
#    include <ffitarget_arm.h>
#  else
#    error "Unknown linux arch."
#  endif
#elif defined(__APPLE__)
#    include <ffitarget_macosx.h>
#else
#  error "Unknown platform."
#endif
