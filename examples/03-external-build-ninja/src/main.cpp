#include <iostream>

int main(int argc, char** argv) {
    std::cout << "ninja-lab" << '\n';
    std::cout << "argc=" << argc << '\n';

    if (argc > 1) {
        std::cout << "arg1=" << argv[1] << '\n';
    }

    return 0;
}

