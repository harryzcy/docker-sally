FROM golang:1.22.6@sha256:2bd56f00ff47baf33e64eae7996b65846c7cb5e0a46e0a882ef179fd89654afa as builder

RUN CGO_ENABLED=0 go install -ldflags="-w -s" go.uber.org/sally@v1.6.0

FROM busybox:1.36.1-glibc@sha256:25e9fcbd3799fce9c0ec978303d35dbb18a6ffb1fc76fc9b181dd4e657e2cd13 as health

FROM gcr.io/distroless/base:nonroot@sha256:a9899ccd9868bbd8913c67f6807410abecf766bc9e3c718eb6248f7b3dfb9819

USER nonroot:nonroot
COPY --from=builder --chown=nonroot:nonroot /go/bin/sally /bin/
COPY --from=health --chown=nonroot:nonroot /bin/wget /bin/

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=30s --start-period=5s --retries=3 \
  CMD [ "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/", "||", "exit", "1" ]

CMD ["/bin/sally"]
