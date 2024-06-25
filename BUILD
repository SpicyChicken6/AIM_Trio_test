#zcat ../trio_data/joint_2039856.TACGCTAC-CGTGTGAT_2039872.CTGTGTTG-TAGGAGCT_2039886.GATCCATG-CAACTCCA.vcf.gz | head -10000 > truncated.vcf.gz
#mkdir truncated_output

#docker run -u $(id -u):$(id -g) \
#           -v /mnt/belinda_local/cole/home/trio_pipeline/output/dummy1_fixed.vcf.gz:/input/vcf.gz \
#           -v /mnt/belinda_local/cole/home/trio_data/hpo.txt:/input/hpo.txt \
#           -v /mnt/belinda_local/cole/home/trio_data/data_dependencies_sasi/:/run/data_dependencies \
#           -v /mnt/belinda_local/cole/home/trio_pipeline/output:/out \
#       cole/aim-lite /run/proc.sh dummy1 hg38 20 True > singleton_error_logs.txt


#docker run -u $(id -u):$(id -g) -v /mnt/belinda_local/cole/home/trio_pipeline/truncated_output:/out -v /mnt/belinda_local/cole/home/trio_pipeline/trio_pipeline:/run \
#-v /mnt/atlas_local/chaozhong/data/aim/trio_pipeline:/run/inheritance \
#lucianli123/marrvel-py python \
#/run/merge_inheritance.py /out/rami-test/dummy1_scores.csv \
#/out/final_matrix/dummy1.csv /out/inheritance/dummy1.inheritance.txt /out/inheritance/dummy1.trio.mtx.csv

#docker run -u $(id -u):$(id -g) -v /mnt/belinda_local/cole/home/trio_pipeline/truncated_output:/out -v /mnt/belinda_local/cole/home/trio_pipeline/trio_pipeline:/run \
#-v /mnt/belinda_local/cole/home/trio_pipeline/trio_pipeline/predict_trio:/run/predict_trio \
#chaozhongliu/aimarrvel-trio-python python3.8 /run/predict_trio/run_final.py dummy1

#docker run -u $(id -u):$(id -g) -v /mnt/belinda_local/cole/home/trio_pipeline/truncated_output:/out -v /mnt/belinda_local/cole/home/trio_pipeline/trio_pipeline:/run \
#-v /mnt/belinda_local/cole/home/trio_pipeline/trio_pipeline/predict_trio:/run/predict_trio \
#chaozhongliu/aimarrvel-trio-python python3.8 /run/predict_trio/run_final_NDG.py dummy1

#docker run -u $(id -u):$(id -g) \
#-v /mnt/belinda_local/cole/home/trio_pipeline/truncated_output:/out -v /mnt/belinda_local/cole/home/trio_pipeline/trio_pipeline:/run \
#-v /mnt/belinda_local/cole/home/trio_pipeline/trio_pipeline:/run/inheritance \
#lucianli123/marrvel-py \
#python /run/inheritance/merge_rm_trio.py dummy1


#bash trio_pipeline/proc_trio.sh \
#                /mnt/belinda_local/cole/home/trio_pipeline/truncated.vcf.gz \
#                /mnt/belinda_local/cole/home/trio_data/hpo.txt \
#                dummy1 \
#                /mnt/belinda_local/cole/home/trio_pipeline/trio_pipeline \
#                /mnt/belinda_local/cole/home/trio_data/data_dependencies_sasi/ \
#                /mnt/belinda_local/cole/home/trio_pipeline/truncated_output \
#                /mnt/belinda_local/cole/home/trio_data/pedigree.ped \
#                2039856 \
#                2039886 \
#                2039872 \
#                /mnt/belinda_local/cole/home/trio_pipeline/proc.sh \
#                hg38 2> trunc_error_logs.txt

mkdir output
bash /home/zhijiany/trio_pipeline/trio_pipeline/proc_trio.sh \
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
    hg38 2> error_logs.txt





