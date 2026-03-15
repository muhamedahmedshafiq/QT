# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/appcal_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/appcal_autogen.dir/ParseCache.txt"
  "appcal_autogen"
  )
endif()
