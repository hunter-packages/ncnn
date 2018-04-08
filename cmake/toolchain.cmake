# Encapsulate all global definitions as an optional/convenient "pseudo"-toolchain
# while allowing user to define a custom global shared toolchain.
add_definitions(-Wall -Wextra -Wno-unused-function)
add_definitions(-fPIC)
add_definitions(-Ofast)
add_definitions(-ffast-math)
add_definitions(-fvisibility=hidden -fvisibility-inlines-hidden)
