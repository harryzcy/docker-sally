FROM golang:1.23.4@sha256:7ea4c9dcb2b97ff8ee80a67db3d44f98c8ffa0d191399197007d8459c1453041 as builder

RUN CGO_ENABLED=0 go install -ldflags="-w -s" go.uber.org/sally@v1.6.0

FROM busybox:1.37.0@sha256:2919d0172f7524b2d8df9e50066a682669e6d170ac0f6a49676d54358fe970b5 as health

FROM gcr.io/distroless/base:nonroot@sha256:97d15218016debb9b6700a8c1c26893d3291a469852ace8d8f7d15b2f156920f

USER nonroot:nonroot
COPY --from=builder --chown=nonroot:nonroot /go/bin/sally /bin/
COPY --from=health --chown=nonroot:nonroot /bin/wget /bin/

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=30s --start-period=5s --retries=3 \
  CMD [ "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/", "||", "exit", "1" ]

CMD ["/bin/sally"]
