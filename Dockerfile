FROM golang:1.22.1@sha256:34ce21a9696a017249614876638ea37ceca13cdd88f582caad06f87a8aa45bf3 as builder

RUN CGO_ENABLED=0 go install -ldflags="-w -s" go.uber.org/sally@v1.6.0

FROM busybox:1.36.1-glibc@sha256:8425131865cec8fba4d2db137c883902155e0d58fcbb301690693161cc903910 as health

FROM gcr.io/distroless/base:nonroot@sha256:561d514e28866e557eb7e776fff69751a674b887585f83e9b479b3bc333b333e

USER nonroot:nonroot
COPY --from=builder --chown=nonroot:nonroot /go/bin/sally /bin/
COPY --from=health --chown=nonroot:nonroot /bin/wget /bin/

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=30s --start-period=5s --retries=3 \
  CMD [ "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/", "||", "exit", "1" ]

CMD ["/bin/sally"]
