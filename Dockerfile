FROM golang:1.21.3-alpine3.18 as builder

RUN CGO_ENABLED=0 go install go.uber.org/sally@v1.5.0

FROM gcr.io/distroless/base
COPY --from=builder /go/bin/sally /bin/

EXPOSE 8080
CMD ["/bin/sally"]
