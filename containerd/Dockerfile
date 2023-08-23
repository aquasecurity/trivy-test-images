FROM ghcr.io/westonsteimel/containerd:1.7.3 as source

FROM alpine:3.18
COPY --from=source /usr/local/bin/containerd /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/containerd"]
CMD ["--help"] 
