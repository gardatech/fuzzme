FROM archlinux AS base
RUN : \
    && pacman --noconfirm -Syu \
        vim nano tmux bash-completion \
        python python-pip \
        base-devel git cmake gdb strace ltrace diffutils \
        clang llvm lld lib32-gcc-libs \
        lcov cloc \
        go \
        jq moreutils \
        pango ttf-liberation \
        geckodriver firefox \
    && fc-cache \
    && :

RUN git config --global advice.detachedHead false

ARG GIT_ANSIFILTER_TAG="2.18"
RUN git clone --depth=1 https://gitlab.com/saalen/ansifilter.git -b ${GIT_ANSIFILTER_TAG} /ansifilter && \
    cd /ansifilter && make && make install && cd / && rm -rf /ansifilter

# go-fuzz with deps
ENV GOPATH /root/go
ENV GO111MODULE=off
WORKDIR $GOPATH
ENV PATH $PATH:/root/.go/bin:$GOPATH/bin

# RUN go version && \
#     go get -u golang.org/dl/gotip && \
#     gotip download && gotip version

RUN go get -u \
        github.com/dvyukov/go-fuzz/go-fuzz \
        github.com/dvyukov/go-fuzz/go-fuzz-build


ARG GIT_AFLPP_TAG="3.14c"
RUN git clone --depth 1 https://github.com/AFLplusplus/AFLplusplus -b ${GIT_AFLPP_TAG} /AFLplusplus
RUN cd /AFLplusplus && \
    # unmute UBSAN
    sed -i 's|cc_params\[cc_par_cnt++\] = "-fsanitize-undefined-trap-on-error";||g' ./src/afl-cc.c && \
    # unmute CFISAN
    sed -i 's|"-fsanitize=cfi";|"-fsanitize=cfi";\n    cc_params\[cc_par_cnt++\] = "-fno-sanitize-trap=cfi";|g' ./src/afl-cc.c && \
    # disable G1 drawing mode of AFL++ status screen
    sed -i 's|#define FANCY_BOXES|// #define FANCY_BOXES|g' ./include/config.h && \
    # increase frequency of fuzzer_stats updates
    sed -i 's|#define STATS_UPDATE_SEC .*$|#define STATS_UPDATE_SEC 5|g' ./include/config.h && \
    make source-only && make install

# script to convert LLVM raw profdata to coverage report
RUN curl https://raw.githubusercontent.com/llvm/llvm-project/main/llvm/utils/prepare-code-coverage-artifact.py \
        -o /bin/prepare-code-coverage-artifact.py && chmod a+x /bin/prepare-code-coverage-artifact.py


# deps for faster installation of bugbane
RUN : \
    && pip3 install -U pip \
    && pip3 install wheel \
    && pip3 install \
        beautifulsoup4 lxml Jinja2 requests selenium WeasyPrint==52.5 build \
        pytest pytest-mock \
    && :


RUN echo "set -g mouse on" > /etc/tmux.conf && \
    sh -c 'echo set encoding=utf-8 > /root/.vimrc' && \
    echo '. /usr/share/bash-completion/bash_completion' >> ~/.bashrc && \
    echo "export PS1='"'[fuzzme \h] \w \$ '"'" >> ~/.bashrc && \
    mkdir -p /run/tmux



FROM base AS bugbane

ARG GIT_BB_BRANCH=dev
ARG GIT_BB_TAG=f18c870
RUN : \
    && git clone -b ${GIT_BB_BRANCH} https://github.com/gardatech/bugbane /bugbane \
    && cd /bugbane && git reset --hard ${GIT_BB_TAG} && pip3 install -e .[dev] \
    && pytest -q . \
    && :

WORKDIR /



FROM bugbane AS add_src
ADD ${SRC} /src

ENV FUZZ_DURATION=15

# C++ target
FROM add_src AS fuzz_cpp
CMD : \
    && bb-build -vv -i /src/cpp -o /fuzz \
    && cp /src/cpp/bugbane.json /fuzz \
    && bb-fuzz -vv --suite /fuzz \
    && bb-reproduce -vv suite /fuzz \
    && bb-coverage -vv suite /fuzz \
    && bb-report -vv --name report suite /fuzz \
    && bb-corpus -vv suite /fuzz export-to /storage \
    && :


# golang target
FROM add_src AS fuzz_golang

ENV FUZZ_DURATION=30
CMD : \
    && cd /src/go && ./build.sh \
    && mkdir -p /fuzz/gofuzz \
    && mv build/*.zip /fuzz/gofuzz/ \
    && cp /src/go/bugbane.json /fuzz \
    && bb-fuzz -vv --suite /fuzz \
    && bb-coverage -vv suite /fuzz \
    && bb-reproduce -vv suite /fuzz \
    && bb-report -vv --html-screener selenium \
        --name report suite /fuzz \
    && bb-corpus -vv suite /fuzz export-to /storage \
    && :

