find_package(OpenCV REQUIRED)

add_executable(ssdmobilenet ssdmobilenet.cpp)
target_link_libraries(ssdmobilenet ncnn ${OpenCV_LIBS})
install(TARGETS ssdmobilenet DESTINATION bin)

add_executable(ssdsqueezenet ssdsqueezenet.cpp)
target_link_libraries(ssdsqueezenet ncnn ${OpenCV_LIBS})
install(TARGETS ssdsqueezenet DESTINATION bin)
