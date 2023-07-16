FROM golang:1.20.6-alpine3.18 as builder

RUN CGO_ENABLED=0 go install go.uber.org/sally@v1.4.0

FROM gcr.io/distroless/base
COPY --from=builder /go/bin/sally /bin/

EXPOSE 8080
CMD ["/bin/sally"]
