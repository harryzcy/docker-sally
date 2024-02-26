FROM golang:1.21.6-alpine3.19 as builder

RUN CGO_ENABLED=0 go install -ldflags="-w -s" go.uber.org/sally@v1.6.0

FROM gcr.io/distroless/base
COPY --from=builder /go/bin/sally /bin/

EXPOSE 8080
CMD ["/bin/sally"]
