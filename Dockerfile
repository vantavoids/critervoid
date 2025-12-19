FROM alpine:latest AS criterion-builder

RUN apk add --no-cache \
    build-base \
    git \
    meson \
    samurai \
    cmake \
    libffi-dev \
    pkgconf

WORKDIR /tmp/criterion-build
RUN git clone --depth 1 https://github.com/Snaipe/Criterion.git && \
    cd Criterion && \
    meson build --strip && \
    ninja -C build && \
    ninja -C build install && \
    strip /usr/local/lib/libcriterion.so*

FROM alpine:latest

ENV TERM=xterm-256color \
    LD_LIBRARY_PATH=/usr/local/lib \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

RUN apk add --no-cache \
    clang \
    clang-dev \
    musl-dev \
    make \
    pkgconf \
    libffi \
    bash

COPY --from=criterion-builder /usr/local/lib/libcriterion* /usr/local/lib/
COPY --from=criterion-builder /usr/local/include/criterion /usr/local/include/criterion
COPY --from=criterion-builder /usr/local/lib/pkgconfig/criterion.pc /usr/local/lib/pkgconfig/

RUN ln -sf /usr/bin/clang /usr/bin/cc && \
    ln -sf /usr/bin/clang++ /usr/bin/c++

WORKDIR /workspace

COPY run-tests.sh /usr/local/bin/run-tests
RUN chmod +x /usr/local/bin/run-tests

RUN echo 'export PS1="[critervoid] \u@\h:\w\$ "' >> /root/.bashrc

CMD ["/bin/bash"]
