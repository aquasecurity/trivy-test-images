FROM ghcr.io/westonsteimel/containerd:1.6.1 as source

FROM alpine:3.15
COPY --from=source /usr/local/bin/containerd /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/containerd"]
CMD ["--help"] 
