hunter_add_package(OpenCV)
find_package(OpenCV REQUIRED)

add_executable(squeezenet squeezenet.cpp)
target_link_libraries(squeezenet ncnn ${OpenCV_LIBS})
install(TARGETS squeezenet DESTINATION bin)

add_executable(fasterrcnn fasterrcnn.cpp)
target_link_libraries(fasterrcnn ncnn ${OpenCV_LIBS})
install(TARGETS fasterrcnn DESTINATION bin)

add_subdirectory(ssd)
