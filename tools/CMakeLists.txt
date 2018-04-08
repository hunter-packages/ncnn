add_subdirectory(caffe)
add_subdirectory(mxnet)

add_executable(ncnn2mem ncnn2mem.cpp)
target_link_libraries(ncnn2mem ncnn)
install(TARGETS ncnn2mem EXPORT ${TARGETS_EXPORT_NAME} DESTINATION bin COMPONENT bin)
