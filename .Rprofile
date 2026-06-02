# Clear stale PKG_CPPFLAGS set by rstan in prior sessions.
# Without this, R CMD SHLIB fails because Stan/Eigen C++ headers
# get injected into plain C compilations.
Sys.unsetenv("PKG_CPPFLAGS")
