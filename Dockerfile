FROM golang:1.22.2@sha256:b994e2c814955c73b9f93df71fde626a5c8aade26eb0de6e721a92d59eed5b3a as builder

RUN CGO_ENABLED=0 go install -ldflags="-w -s" go.uber.org/sally@v1.6.0

FROM busybox:1.36.1-glibc@sha256:cb6aeb580841ccd038a2fb39a9d89948a4eced95ed02c1f726d599da65c8f0c5 as health

FROM gcr.io/distroless/base:nonroot@sha256:0ba510e7d2cd07b3481c6760b2f571724b337d56a6788b9d28d62afa3a0d9371

USER nonroot:nonroot
COPY --from=builder --chown=nonroot:nonroot /go/bin/sally /bin/
COPY --from=health --chown=nonroot:nonroot /bin/wget /bin/

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=30s --start-period=5s --retries=3 \
  CMD [ "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/", "||", "exit", "1" ]

CMD ["/bin/sally"]
