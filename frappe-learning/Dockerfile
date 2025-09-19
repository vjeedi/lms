# FROM frappe/bench:latest

# USER root

# # Copy init.sh into image
# COPY --chown=frappe:frappe init.sh /workspace/init.sh
# RUN chmod +x /workspace/init.sh 

# USER frappe
# WORKDIR /home/frappe

# CMD ["bash", "/workspace/init.sh"]

FROM frappe/bench:latest

WORKDIR /home/frappe

# Copy init script into a safe location
COPY --chown=frappe:frappe init.sh /opt/init.sh
RUN chmod +x /opt/init.sh

# Declare volume for bench data
VOLUME ["/workspace"]

# Run init script on container start
CMD ["bash", "/opt/init.sh"]
