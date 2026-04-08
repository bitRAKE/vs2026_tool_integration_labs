#include <cstdlib>
#include <iostream>

int main(int argc, char** argv) {
    const char* profile = std::getenv("VSF_PROFILE");
    const char* out_dir = std::getenv("VSF_OUT_DIR");

    std::cout << "profile=" << (profile ? profile : "manual") << '\n';
    std::cout << "out_dir=" << (out_dir ? out_dir : "unset") << '\n';
    std::cout << "argc=" << argc << '\n';

    if (argc > 1) {
        std::cout << "arg1=" << argv[1] << '\n';
    }

    return 0;
}

