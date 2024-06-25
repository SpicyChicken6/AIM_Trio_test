
# Merge gVCFs using GLnexus
docker run --rm -i -v $(pwd):/in ghcr.io/dnanexus-rnd/glnexus:v1.4.1 \
    bash -c 'glnexus_cli --config DeepVariant /in/*.g.vcf.gz' > S185_186_187_trio.bcf


bcftools view S185_186_187_trio.bcf | bgzip -@ 4 -c > S185_186_187_trio.vcf.gz

#run aim trio
## use hg38 reference : /home/zhijiany/work_dir/references/Homo_sapiens/GATK/GRCh38/Sequence/WholeGenomeFasta/Homo_sapiens_assembly38.fasta
bash /home/zhijiany/trio_pipeline/trio_pipeline/proc_trio_hg38.sh \
    /home/zhijiany/work_dir/06202024/input/VCFs/S185_186_187_trio.vcf.gz \
    /home/zhijiany/work_dir/06202024/input/HPO/BCM427_HPO.txt \
    trio185 \
    /home/zhijiany/trio_pipeline/trio_pipeline \
    /home/sasidhar/1023 \
    /home/zhijiany/work_dir/06202024/output \
    /home/zhijiany/work_dir/06202024/input/trio.ped \
    1216620_S185 \
    1216621_S186 \
    1216622_S187 \
    /home/zhijiany/trio_pipeline/trio_pipeline/proc.sh \
    hg38 > /home/zhijiany/work_dir/06202024/full_logs.txt 2>&1

#for the vini case
bash /home/zhijiany/trio_pipeline/trio_pipeline/proc_trio_hg38.sh \
    /home/zhijiany/work_dir/06242024/input/merged.vcf.gz \
    /home/zhijiany/work_dir/06242024/input/hpos.txt \
    trio_vini \
    /home/zhijiany/trio_pipeline/trio_pipeline \
    /home/sasidhar/1023 \
    /home/zhijiany/work_dir/06242024/output \
    /home/zhijiany/work_dir/06242024/input/pedigree.ped \
    2400125487.targeted \
    2400125488.targeted \
    2400125489.targeted \
    /home/zhijiany/trio_pipeline/trio_pipeline/proc.sh \
    hg38 > /home/zhijiany/work_dir/06242024/full_logs.txt 2>&1



#build docker from local image
##
cd /mnt/belinda_local/cole/home/trio_pipeline/fixed_singleton_pipeline/AI_MARRVEL/
docker build -t cole/aim-lite:latest .