
# reference path /home/zhijiany/work_dir/references/Homo_sapiens/GATK/GRCh38/Sequence/WholeGenomeFasta/Homo_sapiens_assembly38.fasta
INPUT_DIR="/home/zhijiany/work_dir/06032024/deeptrio/input"
OUTPUT_DIR="/home/zhijiany/work_dir/06032024/deeptrio"
BIN_VERSION="1.6.1"

# complete run
docker run \
  -u $(id -u):$(id -g) \
  -v "${INPUT_DIR}":"/input" \
  -v "${OUTPUT_DIR}/output":"/output" \
  --memory="30g" \
  --memory-swap="30g" \
  google/deepvariant:deeptrio-"${BIN_VERSION}" \
  /opt/deepvariant/bin/deeptrio/run_deeptrio \
  --model_type=WGS \
  --ref=/input/Homo_sapiens_assembly38.fasta \
  --reads_child=/input/S185.md.bam \
  --reads_parent1=/input/S186.md.bam \
  --reads_parent2=/input/S187.md.bam \
  --output_vcf_child /output/S185.output.vcf.gz \
  --output_vcf_parent1 /output/S186.output.vcf.gz \
  --output_vcf_parent2 /output/S187.output.vcf.gz \
  --sample_name_child 'S185' \
  --sample_name_parent1 'S186' \
  --sample_name_parent2 'S187' \
  --num_shards 15  \
  --intermediate_results_dir /output/intermediate_results_dir \
  --output_gvcf_child /output/S185.g.vcf.gz \
  --output_gvcf_parent1 /output/S186.g.vcf.gz \
  --output_gvcf_parent2 /output/S187.g.vcf.gz \
  > "${OUTPUT_DIR}/logs.txt" 2>&1
# non-PAR region X
docker run \
  -u $(id -u):$(id -g) \
  -v "${INPUT_DIR}":"/input" \
  -v "${OUTPUT_DIR}/nonPAR_X/output":"/output" \
  google/deepvariant:deeptrio-"${BIN_VERSION}" \
  /opt/deepvariant/bin/deeptrio/run_deeptrio \
  --model_type=WGS \
  --ref=/input/Homo_sapiens_assembly38.fasta \
  --reads_child=/input/S185.md.bam \
  --reads_parent1=/input/S186.md.bam \
  --output_vcf_child /output/S185_nonPAR_X.output.vcf.gz \
  --output_vcf_parent1 /output/S186_nonPAR_X.output.vcf.gz \
  --sample_name_child 'S185' \
  --sample_name_parent1 'S186' \
  --num_shards 15  \
  --regions "chrX:2781480-155701382" \
  --intermediate_results_dir /output/intermediate_results_dir \
  --output_gvcf_child /output/S185_nonPAR_X.g.vcf.gz \
  --output_gvcf_parent1 /output/S186_nonPAR_X.g.vcf.gz \
  > "${OUTPUT_DIR}/nonPAR_X/logs.txt" 2>&1

# non-PAR region Y
docker run \
  -u $(id -u):$(id -g) \
  -v "${INPUT_DIR}":"/input" \
  -v "${OUTPUT_DIR}/nonPAR_Y/output":"/output" \
  google/deepvariant:deeptrio-"${BIN_VERSION}" \
  /opt/deepvariant/bin/deeptrio/run_deeptrio \
  --model_type=WGS \
  --ref=/input/Homo_sapiens_assembly38.fasta \
  --reads_child=/input/S185.md.bam \
  --reads_parent1=/input/S187.md.bam \
  --output_vcf_child /output/S185_nonPAR_Y.output.vcf.gz \
  --output_vcf_parent1 /output/S187_nonPAR_Y.output.vcf.gz \
  --sample_name_child 'S185' \
  --sample_name_parent1 'S187' \
  --num_shards 15  \
  --regions "chrY:2781480-56887901" \
  --intermediate_results_dir /output/intermediate_results_dir \
  --output_gvcf_child /output/S185_nonPAR_Y.g.vcf.gz \
  --output_gvcf_parent1 /output/S187_nonPAR_Y.g.vcf.gz \
  > "${OUTPUT_DIR}/nonPAR_Y/logs.txt" 2>&1


# concatenate the vcf results
# S185
bcftools view -t ^chrX:2781480-155701382,chrY:2781480-56887901 --targets-overlap 2 S185.output.vcf.gz -Oz -o S185_whole_genome_no_nonPAR_XY.vcf.gz
bcftools index output/S185_whole_genome_no_nonPAR_XY.vcf.gz
bcftools concat -a output/S185_whole_genome_no_nonPAR_XY.vcf.gz nonPAR_X/output/S185_nonPAR_X.output.vcf.gz nonPAR_Y/output/S185_nonPAR_Y.output.vcf.gz -Oz -o S185_concatenated.vcf.gz
# S186
bcftools view -t ^chrX:2781480-155701382 --targets-overlap 2 S186.output.vcf.gz -Oz -o S186_whole_genome_no_nonPAR_X.vcf.gz
bcftools index S186_whole_genome_no_nonPAR_X.vcf.gz
bcftools concat -a S186_whole_genome_no_nonPAR_X.vcf.gz S186_nonPAR_X.output.vcf.gz -Oz -o S186_concatenated.vcf.gz
bcftools index S186_concatenated.vcf.gz
# S187
bcftools view -t ^chrY:2781480-56887901 --targets-overlap 2 S187.output.vcf.gz -Oz -o S187_whole_genome_no_nonPAR_Y.vcf.gz
bcftools index S187_whole_genome_no_nonPAR_Y.vcf.gz
bcftools concat -a S187_whole_genome_no_nonPAR_Y.vcf.gz S187_nonPAR_Y.output.vcf.gz -Oz -o S187_concatenated.vcf.gz
bcftools index S187_concatenated.vcf.gz

#run the AIM
docker run \
            -u $(id -u):$(id -g) \
            -v /home/zhijiany/work_dir/06032024/deeptrio/HPO_vcf/S185_concatenated.vcf.gz:/input/vcf.gz \
            -v /home/zhijiany/work_dir/06032024/deeptrio/HPO_vcf/BCM427_HPO.txt:/input/hpo.txt \
            -v /home/sasidhar/1023:/run/data_dependencies \
            -v /home/zhijiany/work_dir/06032024/deeptrio/AIM_results:/out \
            chaozhongliu/aim-lite /run/proc.sh lx1 hg38 20



