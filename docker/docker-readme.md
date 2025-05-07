# SimAI Docker

This directory contains a Docker setup for running SimAI in a containerized environment that matches the recommended environment:

- NGC PyTorch (based on Ubuntu 20.04)
- GCC/G++ 9.4.0
- Python 3.8.10

## Directory Structure

- `Dockerfile`: Builds the SimAI Docker image with all necessary dependencies
- `run_simai_docker.sh`: Script to run SimAI simulations in the Docker container

## Building the Docker Image

Build the Docker image from this directory:

```bash
cd docker
sudo docker build -t simai:latest .
```

This creates a Docker image with SimAI installed and ready to use.

## Running SimAI with the Automated Script

The included `run_simai_docker.sh` script automates running SimAI in Docker:

```bash
./run_simai_docker.sh
```

This script:
1. Creates a timestamped results directory (`result_<timestamp>`)
2. Creates an input directory for any custom input files
3. Runs the SimAI simulation in Docker with default parameters
4. Copies all CSV results to the results directory
5. Logs all output to `result_<timestamp>/log.txt`

### Script Options

```bash
./run_simai_docker.sh --skip-topo  # Skip topology creation
```

### Default SimAI Commands

The script automatically runs:

1. Network topology creation:
```bash
python3 ./astra-sim-alibabacloud/inputs/topo/gen_Topo_Template.py -topo Spectrum-X -g 128 -gt A100 -bw 100Gbps -nvbw 2400Gbps
```

2. SimAI simulation:
```bash
AS_SEND_LAT=3 AS_NVLS_ENABLE=1 ./bin/SimAI_simulator -t 16 -w ./example/microAllReduce.txt -n ./Spectrum-X_128g_8gps_100Gbps_A100 -c astra-sim-alibabacloud/inputs/config/SimAI.conf
```

## Running the Container Manually

To run the container with GPU support (recommended):

```bash
sudo docker run --rm --gpus all --runtime=nvidia -it simai:latest
```

To run with volume mounting:

```bash
sudo docker run --rm --gpus all --runtime=nvidia -v $(pwd)/input:/input -v $(pwd)/results:/result -it simai:latest
```

## Inside the Container

The SimAI Docker container includes:

- A fully built SimAI with analytical and NS3 modes
- Helper scripts for common operations:
  - `simai-help`: Shows usage information
  - `run-analytical`: Run the analytical mode
  - `run-ns3`: Run the NS3 simulation mode
  - `gen-topo`: Generate a network topology

## Example Manual Commands

Once inside the container:

1. Generate a network topology:
```bash
gen-topo -topo Spectrum-X -g 16 -gt A100 -bw 100Gbps -nvbw 2400Gbps
```

2. Run SimAI in analytical mode:
```bash
run-analytical -w example/workload_analytical.txt -g 9216 -g_p_s 8 -r test- -busbw example/busbw.yaml
```

3. Run SimAI in NS3 simulation mode:
```bash
run-ns3 -t 4 -w example/microAllReduce.txt -n ./Spectrum-X_16g_8gps_100Gbps_A100 -c astra-sim-alibabacloud/inputs/config/SimAI.conf
```

## Troubleshooting

If you encounter issues with the NS3 simulator:

1. Try running with debug environments:
   ```bash
   ASTRA_DEBUG=1 ASTRA_STAT=1 run-ns3 -t 2 -w ./example/minimal2.txt -n ./Spectrum-X_16g_8gps_100Gbps_A100 -c astra-sim-alibabacloud/inputs/config/SimAI.conf
   ```

2. Check the log file in the results directory

3. Simplify your topology and workload parameters

4. Contact the SimAI team for support (see the SimAI repository README)

## Notes

- The Docker environment is built using NGC PyTorch with the specific GCC/G++ and Python versions required
- SimAI-Analytical mode should work reliably for most workloads
- SimAI-Simulation (NS3) mode might require specific configurations to work correctly
- The Docker container has GDB installed for debugging purposes

For more information on SimAI, see the [official repository](https://github.com/aliyun/SimAI). 