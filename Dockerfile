FROM golang:1.22.2@sha256:aca60c1f21de99aa3a34e653f0cdc8c8ea8fe6480359229809d5bcb974f599ec as builder

RUN CGO_ENABLED=0 go install -ldflags="-w -s" go.uber.org/sally@v1.6.0

FROM busybox:1.36.1-glibc@sha256:cb6aeb580841ccd038a2fb39a9d89948a4eced95ed02c1f726d599da65c8f0c5 as health

FROM gcr.io/distroless/base:nonroot@sha256:1c99fceaba16f833d6eb030c07d6304bce68f18350e1a0c69a85b8781afc00d9

USER nonroot:nonroot
COPY --from=builder --chown=nonroot:nonroot /go/bin/sally /bin/
COPY --from=health --chown=nonroot:nonroot /bin/wget /bin/

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=30s --start-period=5s --retries=3 \
  CMD [ "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/", "||", "exit", "1" ]

CMD ["/bin/sally"]
