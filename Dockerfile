FROM rust:1.65.0-buster as rust-target
#RUN rustup default nightly
#RUN cargo install afl

RUN apt-get update && apt-get install -y build-essential libvpx-dev \
libx264-dev libmp3lame-dev wget yasm clang

ADD . /rsmpeg
WORKDIR /rsmpeg
RUN ./utils/linux_ffmpeg.rs
ENV FFMPEG_PKG_CONFIG_PATH=/rsmpeg/tmp/ffmpeg_build/lib/pkgconfig

# Harness
ADD ./fuzzers/fuzz_rsmpeg_dump.rs ./fuzzers/
ADD ./fuzzers/Cargo.toml ./fuzzers/
WORKDIR ./fuzzers/
#RUN cargo afl build
RUN cargo build
# ./fuzzers/target/debug/fuzz

# Corpus
RUN wget https://github.com/strongcourage/fuzzing-corpus/raw/master/jpg/mozilla/000_jpg.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/raw/master/jpg/mozilla/1273601738_titanic2.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/raw/master/jpg/mozilla/1326356502_l.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/raw/master/jpg/mozilla/445394673_a9b3a4302a.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/raw/master/jpg/mozilla/9efd60f04cd971daa83d3131e6d6f389.jpg

FROM rust:1.65.0-buster
RUN apt-get update && apt-get install -y build-essential libvpx-dev \
libx264-dev libmp3lame-dev
COPY --from=rust-target /rsmpeg/fuzzers/target/debug/ /debug/
COPY --from=rust-target /rsmpeg/fuzzers/*.jpg /testsuite/
COPY --from=rust-target /rsmpeg/tmp/ffmpeg_build/lib/pkgconfig /ffmpeg_build/lib/pkgconfig/
ENV FFMPEG_PKG_CONFIG_PATH=/ffmpeg_build/lib/pkgconfig

ENTRYPOINT []
CMD ["/debug/fuzz_rsmpeg_dump", "@@"]
