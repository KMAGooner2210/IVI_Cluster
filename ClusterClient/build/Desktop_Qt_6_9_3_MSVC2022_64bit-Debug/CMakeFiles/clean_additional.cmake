# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appClusterClient_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appClusterClient_autogen.dir\\ParseCache.txt"
  "appClusterClient_autogen"
  )
endif()
