# Cap calculator retries so failed tests abort quickly rather than retrying 5x.
# Must be set before fz Python module is first imported.
Sys.setenv(FZ_MAX_RETRIES = "1")
