FROM golang:1.23.1@sha256:3a95a7febf5a68fadbec6b0d55de883f26d6b62792d5b0c4d17114d45d6123b4 as builder

RUN CGO_ENABLED=0 go install -ldflags="-w -s" go.uber.org/sally@v1.6.0

FROM busybox:1.36.1-glibc@sha256:949757861bcee7514f64d9b44d3c1d43c21f5183cae113e97b98261fc1c522dc as health

FROM gcr.io/distroless/base:nonroot@sha256:e5260be292def77bc70d03003f788f3d32c0796972ea1412d72cc0c843ab139a

USER nonroot:nonroot
COPY --from=builder --chown=nonroot:nonroot /go/bin/sally /bin/
COPY --from=health --chown=nonroot:nonroot /bin/wget /bin/

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=30s --start-period=5s --retries=3 \
  CMD [ "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/", "||", "exit", "1" ]

CMD ["/bin/sally"]
