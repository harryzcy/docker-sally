FROM golang:1.23.3@sha256:26602182e32576fca9ad5397fd74b87ae68f7ee727436a85dd19a1c3766ad685 as builder

RUN CGO_ENABLED=0 go install -ldflags="-w -s" go.uber.org/sally@v1.6.0

FROM busybox:1.37.0@sha256:768e5c6f5cb6db0794eec98dc7a967f40631746c32232b78a3105fb946f3ab83 as health

FROM gcr.io/distroless/base:nonroot@sha256:350980ee07b2fc28336bb730cdb02b7c83d4a4d7832b1a49c827c8cc28f7f06b

USER nonroot:nonroot
COPY --from=builder --chown=nonroot:nonroot /go/bin/sally /bin/
COPY --from=health --chown=nonroot:nonroot /bin/wget /bin/

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=30s --start-period=5s --retries=3 \
  CMD [ "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/", "||", "exit", "1" ]

CMD ["/bin/sally"]
