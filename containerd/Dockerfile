FROM ghcr.io/westonsteimel/containerd:1.6.1 as source

FROM alpine
COPY --from=source /usr/local/bin/containerd /usr/local/bin/
RUN apk add bash
ENTRYPOINT ["/usr/local/bin/containerd"]
CMD ["--help"] 