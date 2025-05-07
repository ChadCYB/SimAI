FROM nvcr.io/nvidia/pytorch:22.04-py3

LABEL maintainer="SimAI User <user@example.com>"
LABEL description="Docker image for SimAI simulator with NGC PyTorch (Ubuntu 20.04), GCC/G++ 9.4.0, and Python 3.8.10"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install specific versions of GCC/G++ 9.4.0
RUN apt-get update && apt-get install -y \
    gcc-9 \
    g++-9 \
    python3.8 \
    python3.8-dev \
    python3.8-venv \
    libboost-all-dev \
    gdb \
    vim \
    htop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set GCC/G++ 9.4.0 as the default compiler and Python 3.8.10
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 100 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.8 100

# Verify versions match requirements
RUN gcc --version && g++ --version && python3 --version

# Remove ninja as it interferes with SimAI compilation
RUN apt-get update && apt-get remove -y ninja-build \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip uninstall -y ninja

# Create workspace directory
WORKDIR /workspace

# Clone SimAI repository and submodules
RUN git clone https://github.com/aliyun/SimAI.git \
    && cd SimAI \
    && git submodule update --init --recursive \
    && git submodule update --remote

# Build SimAI
WORKDIR /workspace/SimAI
RUN ./scripts/build.sh -c analytical \
    && ./scripts/build.sh -c ns3

# Set environment variables that may be helpful
ENV PATH="/workspace/SimAI/bin:${PATH}"
ENV LD_LIBRARY_PATH="/workspace/SimAI/astra-sim-alibabacloud/build/simai_analytical/build/simai_analytical:${LD_LIBRARY_PATH}"

# Create a useful helper script
RUN echo '#!/bin/bash\n\
echo "===== SimAI Docker Container ====="\n\
echo "Available commands:"\n\
echo "  - run-analytical: Run SimAI in analytical mode"\n\
echo "  - run-ns3: Run SimAI in NS3 simulation mode"\n\
echo "  - gen-topo: Generate a network topology"\n\
echo ""\n\
echo "Example usage:"\n\
echo "  run-analytical -w example/workload_analytical.txt -g 9216 -g_p_s 8 -r test- -busbw example/busbw.yaml"\n\
echo "  gen-topo -topo Spectrum-X -g 16 -gt A100 -bw 100Gbps -nvbw 2400Gbps"\n\
echo "  run-ns3 -t 4 -w example/microAllReduce.txt -n ./Spectrum-X_16g_8gps_100Gbps_A100 -c astra-sim-alibabacloud/inputs/config/SimAI.conf"\n\
' > /usr/local/bin/simai-help && chmod +x /usr/local/bin/simai-help

# Create helper scripts for common commands
RUN echo '#!/bin/bash\n\
./bin/SimAI_analytical "$@"\n\
' > /usr/local/bin/run-analytical && chmod +x /usr/local/bin/run-analytical

RUN echo '#!/bin/bash\n\
AS_SEND_LAT=3 AS_NVLS_ENABLE=1 ./bin/SimAI_simulator "$@"\n\
' > /usr/local/bin/run-ns3 && chmod +x /usr/local/bin/run-ns3

RUN echo '#!/bin/bash\n\
python3 ./astra-sim-alibabacloud/inputs/topo/gen_Topo_Template.py "$@"\n\
' > /usr/local/bin/gen-topo && chmod +x /usr/local/bin/gen-topo

# Create README inside container
RUN echo "# SimAI Docker Container\n\n\
This container provides a ready-to-use environment for SimAI simulation with:\n\
- NGC PyTorch (based on Ubuntu 20.04)\n\
- GCC/G++ 9.4.0\n\
- Python 3.8.10\n\n\
## Usage\n\n\
Run 'simai-help' to see available commands and examples.\n\n\
## Modes\n\n\
- Analytical Mode: Fast simulation using bus bandwidth abstraction\n\
- NS3 Mode: Detailed network simulation\n\n\
## Documentation\n\n\
For more information, see: https://github.com/aliyun/SimAI\n\
" > /workspace/README.md

# Set working directory to SimAI
WORKDIR /workspace/SimAI

# Default command opens bash
CMD ["/bin/bash"]