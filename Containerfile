FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

FROM ghcr.io/ublue-os/silverblue-main:44

ARG VERSION=latest
LABEL org.opencontainers.image.version="${VERSION}"

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    VERSION="${VERSION}" /ctx/build.sh

# Record the release version in os-release (shown by `bootc status`, os-release).
RUN echo "IMAGE_VERSION=${VERSION}" >> /usr/lib/os-release

RUN bootc container lint
