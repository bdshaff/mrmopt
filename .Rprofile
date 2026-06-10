# Clear stale PKG_CPPFLAGS set by rstan in prior sessions.
# Without this, R CMD SHLIB fails because Stan/Eigen C++ headers
# get injected into plain C compilations.
Sys.unsetenv("PKG_CPPFLAGS")

# Set SDKROOT to the active macOS SDK so C++ standard library headers
# (e.g. <cmath>) are found during R CMD build. Without this, clang on
# macOS 15+ can fail with 'cmath file not found'.
local({
  sdk <- tryCatch(
    system("xcrun --sdk macosx --show-sdk-path", intern = TRUE),
    error = function(e) ""
  )
  if (nchar(sdk) > 0) Sys.setenv(SDKROOT = sdk)
})
