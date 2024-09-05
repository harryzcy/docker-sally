FROM golang:1.23.0@sha256:613a108a4a4b1dfb6923305db791a19d088f77632317cfc3446825c54fb862cd as builder

RUN CGO_ENABLED=0 go install -ldflags="-w -s" go.uber.org/sally@v1.6.0

FROM busybox:1.36.1-glibc@sha256:0fcfe38431d903645afa509f1a1109be4e209986986d634767f6744eb5869e22 as health

FROM gcr.io/distroless/base:nonroot@sha256:604b1b026106d77df632f526a2497b5d91f925f52ade9c0a71bfc98c5860d9a1

USER nonroot:nonroot
COPY --from=builder --chown=nonroot:nonroot /go/bin/sally /bin/
COPY --from=health --chown=nonroot:nonroot /bin/wget /bin/

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=30s --start-period=5s --retries=3 \
  CMD [ "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/", "||", "exit", "1" ]

CMD ["/bin/sally"]
