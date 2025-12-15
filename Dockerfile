FROM n8nio/n8n:latest

# Set working directory
WORKDIR /home/node

# Set timezone
ENV TZ=Asia/Jakarta
ENV GENERIC_TIMEZONE=Asia/Jakarta

# Copy workflows
COPY workflows /home/node/.n8n/workflows

# Expose port
EXPOSE 5678

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
    CMD wget --quiet --tries=1 --spider http://localhost:5678/healthz || exit 1

# Start n8n
CMD ["n8n"]
