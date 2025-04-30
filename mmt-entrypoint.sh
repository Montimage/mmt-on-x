#!/bin/sh
# This script handles running MMT probe in the container
# It supports three modes:
# 1. Direct host interface monitoring
# 2. Netcat mode for receiving traffic
# 3. PCAP file analysis

# Check if a PCAP file is provided
if [ -n "${PCAP_FILE}" ]; then
    echo "Running in PCAP analysis mode, analyzing file: ${PCAP_FILE}"
    
    # Check if the PCAP file exists
    if [ ! -f "${PCAP_FILE}" ]; then
        echo "Error: PCAP file not found at ${PCAP_FILE}"
        exit 1
    fi
    
    # Run MMT probe with the specified PCAP file
    mmt-probe -t "${PCAP_FILE}"

# Check if a host interface is provided
elif [ -n "${HOST_INTERFACE}" ]; then
    echo "Available network interfaces:"
    ip -o link show | awk -F': ' '{print $2}'
    echo "Running in host network interface mode, monitoring: ${HOST_INTERFACE}"
    
    # Run MMT probe directly on the specified network interface
    mmt-probe -i "${HOST_INTERFACE}"

# Default to netcat mode
else
    echo "Running in netcat mode, connecting to host.docker.internal:12345"
    
    # Run MMT probe with netcat input
    nc host.docker.internal 12345 | mmt-probe -t -
fi
