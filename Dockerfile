FROM golang:1.24-alpine AS builder
WORKDIR /app

# Install build tools and LMDB headers
RUN apk add --no-cache git gcc musl-dev lmdb-dev

COPY . .
RUN go mod download

# Enable CGO so LMDB can be compiled
RUN CGO_ENABLED=1 GOOS=linux go build -p 1 -o groups-relay .

FROM alpine:latest
WORKDIR /app

# Install the LMDB runtime library
RUN apk add --no-cache ca-certificates lmdb

COPY --from=builder /app/groups-relay .
EXPOSE 7000
CMD ["./groups-relay"]
