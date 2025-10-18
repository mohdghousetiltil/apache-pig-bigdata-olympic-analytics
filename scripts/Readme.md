## 🚀 Implementation & Execution

### **Technical Architecture**
- **Data Processing Scripts**: `task1.pig`, `task2-1.pig`, `task2-2.pig`
- **Custom UDF Module**: `task2udf.py` (Python User Defined Function)

### Execution Workflow

1. **Cluster Initialization**
   - Access the jump host via SSH
   - Provision the EMR cluster using `./create_cluster.sh`
   - Establish connection to the master node

2. **Data Ingestion**
   - Upload all CSV datasets and the Python UDF to HDFS input directory
   - Deploy Apache Pig scripts to the master node

3. **Pipeline Execution**
   - Execute the analytics pipeline sequentially:
     ```bash
     pig task1.pig
     pig task2-1.pig  
     pig task2-2.pig
     ```
