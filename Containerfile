ARG BASE_IMAGE=ghcr.io/ublue-os/bluefin-dx:gts

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY ./scripts /scripts
# COPY ./files /files

# Base Image
FROM ${BASE_IMAGE}

# Can be used to copy stuff directly into the OS
# COPY --from=ctx files/base/ /

ADD --chmod=0755 scripts/* /scripts

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=bind,from=ctx,src=/scripts,dst=/buildcontext/scripts/ \
    --mount=type=bind,from=ctx,src=/scripts/helpers,dst=/buildcontext/scripts/helpers/ \
    bash /buildcontext/scripts/setup.sh && \
    bash /buildcontext/scripts/cleanup.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
