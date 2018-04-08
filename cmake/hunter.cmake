option(HUNTER_ENABLED "Enable Hunter package manager support" OFF)
include("cmake/HunterGate.cmake")
HunterGate(
    URL "https://github.com/ruslo/hunter/archive/v0.20.27.tar.gz"
    SHA1 "aafefc6377dc9a25d84703702e22434cd6f71d5c"
)
