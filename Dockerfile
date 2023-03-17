FROM golang:1.20.2-alpine3.17 as builder

RUN CGO_ENABLED=0 go install go.uber.org/sally@v1.3.0

FROM gcr.io/distroless/base
COPY --from=builder /go/bin/sally /bin/

EXPOSE 5000
CMD ["/bin/sally", "-yml", "site.yaml", "-port", "5000"]
