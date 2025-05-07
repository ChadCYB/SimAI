#!/bin/bash
set -e  # Exit on any error

# Display container info
echo "Running in SimAI Docker container..."
echo "Date: $(date)"
# echo "Working directory: $(pwd)"
# echo "Listing files in current directory:"
# ls -la

# First change to the SimAI directory
cd /workspace/SimAI
echo "Changed to SimAI directory: $(pwd)"
# echo "Listing SimAI files:"
# ls -la | head -10
# echo "..."

# Create network topology if not skipped
# if [[ "$1" != "skip-topo" ]]; then
#   echo "Creating network topology..."
#   python3 ./astra-sim-alibabacloud/inputs/topo/gen_Topo_Template.py -topo Spectrum-X -g 128 -gt A100 -bw 100Gbps -nvbw 2400Gbps
#   echo "Topology created successfully!"
#   echo ""
# fi

python3 ./astra-sim-alibabacloud/inputs/topo/gen_Topo_Template.py --ro -g 32 -gt H100 -bw 400Gbps -nvbw 1440Gbps

# Run SimAI simulator
echo "Running SimAI simulator..."
echo ""

# Record start time
start_time=$(date +%s)

export AS_SEND_LAT=3 
export AS_NVLS_ENABLE=1 
./bin/SimAI_simulator -t 16 -w ./example/microAllReduce.txt -n /input/topology -c astra-sim-alibabacloud/inputs/config/SimAI.conf
# ./bin/SimAI_simulator -t 8 -w ./example/microAllReduce.txt -n ./Rail_Opti_SingleToR_32g_8gps_400Gbps_H100 -c ./astra-sim-alibabacloud/inputs/config/SimAI.conf

# Calculate and display execution time
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo ""
echo "Simulation complete!"
echo "Total execution time: ${execution_time} seconds"

# Copy results to the mapped result folder
echo "Copying CSV files to result folder..."
cp /workspace/SimAI/*.csv /result/
echo "Copying ns3 files to result folder..."
cp /etc/astra-sim/simulation/* /result/
echo "Results copied successfully."

