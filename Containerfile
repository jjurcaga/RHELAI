# Stage 1: Final RHEL AI 3.2 CUDA Image
FROM registry.redhat.io/rhelai3/bootc-cuda-rhel9:latest

# 2. Use the variables in your RUN commands
# Note the use of ${VARIABLE_NAME}
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf install -y firewalld wget nginx nmon && \
    dnf clean all



# Copy the tmpfiles config to ensure /var folders are created at boot
COPY configs/nginx/nginx-storage.conf /usr/lib/tmpfiles.d/nginx-storage.conf

# This ensures the folders exist in the image and have the right labels before first boot
RUN systemd-tmpfiles --create /usr/lib/tmpfiles.d/nginx-storage.conf

# Copy the NGINX configuration file
COPY configs/nginx/vllm.conf /etc/nginx/conf.d/vllm.conf

# Copy NGINX CRT file
COPY configs/nginx/universal-constructor.crt /etc/nginx/ssl/universal-constructor.crt

# Copy NGINX KEY file
COPY configs/nginx/universal-constructor.key /etc/nginx/ssl/universal-constructor.key

# Copy NGINX KEY file
COPY configs/firewalld/public.xml /etc/firewalld/zones/public.xml

# Enable services so they start automatically on boot
RUN systemctl enable nginx

# Enable firewalld
RUN systemctl enable firewalld

# Ensure SELinux context for Nginx is correct (optional but recommended)
RUN fixfiles -R nginx restore || true

# Final safety check
RUN bootc container lint

