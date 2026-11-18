# Kodus's RabbitMQ build: RabbitMQ 4.2.2 with the delayed-message-exchange
# plugin, creating the kodus-ai and kodus-ast vhosts on start.
FROM ghcr.io/kodustech/kodus-rabbitmq:4.2.2-kodus.1@sha256:38ac44196336dbd293921c15e4ff56d0e8a21d121a3e3a716fcc3d51eeaffbf1

# A fixed node name keeps the broker's data (/var/lib/rabbitmq, on a Railway
# volume) attached to the same node after every redeploy, whatever hostname
# Railway gives the new container.
ENV RABBITMQ_NODENAME=rabbit@localhost \
    RABBITMQ_USE_LONGNAME=false \
    RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="-rabbit heartbeat 60"

COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh

# 5672 = AMQP (private network only; the management UI is not exposed)
EXPOSE 5672
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["/usr/local/bin/init-definitions.sh"]
