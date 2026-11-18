# MongoDB for Kodus (pull request and review history). Kodus needs MongoDB 8.
FROM mongo:8.2.12@sha256:e0ce8c35124d4a9f9785532d1f268f39e9728ffa1cb38f46fa482436424c4bd3

# MongoDB 8 exits on Linux 6.19+ hosts unless glibc uses restartable
# sequences (SERVER-121912); this keeps it starting on every Railway host.
ENV GLIBC_TUNABLES=glibc.pthread.rseq=1

EXPOSE 27017
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mongod", "--bind_ip_all", "--ipv6"]
