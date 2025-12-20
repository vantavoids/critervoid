# Critervoid

A containerized testing environment with [Criterion](https://github.com/Snaipe/Criterion) pre-installed for C/C++ unit testing.

## Usage

Run from any project directory containing a `tests` folder (which, obviously, contains criterion tests suites :p):

```bash
docker run -it -v $(pwd):/workspace ghcr.io/vantavoids/critervoid:main
```

### Recommended: Create an alias

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias critervoid='docker run -it -v $(pwd):/workspace ghcr.io/vantavoids/critervoid:main'
```

Then simply use:

```bash
critervoid
```

### File Permissions

The container runs as a non-root user (UID 1000, GID 1000) by default to avoid permission issues with mounted volumes. Files created inside the container will be owned by this user.

If your host user has a different UID/GID, you can:

**Option 1: Run with your host user ID** (recommended for ad-hoc usage)
```bash
docker run -it --user $(id -u):$(id -g) -v $(pwd):/workspace ghcr.io/vantavoids/critervoid:main
```

**Option 2: Build with your user ID** (recommended if building locally)
```bash
docker build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) -t critervoid .
```

**Option 3: Run as root** (not recommended, but sometimes necessary)
```bash
docker run -it --user root -v $(pwd):/workspace ghcr.io/vantavoids/critervoid:main
```

## What's Included

- **Criterion v2.4.2** - Unit testing framework
- **GCC & Clang** - C/C++ compilers
- **Build tools** - make, cmake, meson, ninja
- **Debugging tools** - gdb, valgrind
- **Text editor** - vim

## Example Test Structure

Your project should have a `tests` directory:

```
your-project/
├── src/
│   └── your_amazing_and_definitely_not_broken_code.c
└── tests/
    └── nuke_your_code.c
```

## Running Tests

### Interactive Mode

Inside the container:

```bash
# Compile and run a single test file
cc tests/test_example.c -o test_runner -lcriterion && ./test_runner

# With verbose output
cc tests/test_example.c -o test_runner -lcriterion && ./test_runner --verbose

# Using make (if you have a Makefile)
make test
```

### Automated Test Runner

Use the included `run-tests` script to automatically compile and run all tests in your `tests` directory:

```bash
# Inside the container
run-tests

# With verbose output
VERBOSE=1 run-tests

# Use clang instead of gcc
COMPILER=clang run-tests

# Add extra compiler flags
EXTRA_FLAGS="-Wall -Wextra -Werror" run-tests
```

### CI/CD Usage

Run tests non-interactively in CI pipelines:

```bash
docker run --rm -v $(pwd):/workspace ghcr.io/vantavoids/critervoid:main run-tests
```

Environment variables:
- `TESTS_DIR` - Directory containing tests (default: `tests`)
- `COMPILER` - Compiler to use (default: `cc`)
- `VERBOSE` - Enable verbose output (default: `0`, set to `1` for verbose)
- `EXTRA_FLAGS` - Additional compiler flags

## Example Test File

```c
#include <criterion/criterion.h>

Test(suite_name, test_name) {
    cr_assert(1 == 1, "We indeed can trust that 1 is equal to 1");
}

Test(suite_name, another_test) {
    cr_expect_eq(2 + 2, 4, "Math works! :D");
}
