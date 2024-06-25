# Trio case prediction pipeline
# Input: joint VCF files with PED file and individual IDs

#$1 path to joint vcf file
#$2 path to hpo
#$3 unique submission id
#$4 path of main pipeline scripts and dependencies
#$5 path of vep cache and dependencies
#$6 output directory
#$7 ped
#$8 Patient ID
#$9 Mother ID
#$10 Father ID
#$11 AIM pipeline script
#$12 reference genome

SAMPLE_P=$8
SAMPLE_M=$9
SAMPLE_F=${10}
AIM_PL=${11}

# Make output subdirectories
echo $(date +"%T") > $6/whole_log_trio.txt
mkdir -m777 $6/inheritance


# GATK for De Novo Calling
#=======================================================
# gatk software
# dependence files
# get ref genome version
# father mother patient ID extraction
# python docker env envifinne
#=======================================================

echo "Normalize joint VCF file, split multiallelics rows"
docker run -v output:/out -v joint_2039856.TACGCTAC-CGTGTGAT_2039872.CTGTGTTG-TAGGAGCT_2039886.GATCCATG-CAACTCCA.vcf.gz:/temp/joint.vcf.gz \
biocontainers/bcftools:v1.9-1-deb_cv1 \
bcftools norm --multiallelics -both \
              -Oz -o /out/dummy.tmp.vcf.gz \
              /temp/joint.vcf.gz

tabix $6/${3}.tmp.vcf.gz

exit

docker run -v $6:/out \
biocontainers/bcftools:v1.9-1-deb_cv1 \
bcftools norm --rm-dup none \
              -Oz -o /out/${3}.joint.vcf.gz \
              /out/${3}.tmp.vcf.gz

tabix $6/${3}.joint.vcf.gz

rm $6/${3}.tmp.vcf.gz
rm $6/${3}.tmp.vcf.gz.tbi


zcat $6/${3}.joint.vcf.gz | grep '^#CHROM' > $6/vcfheaders.txt

docker run -v $6:/out -v $4:/run \
-v /mnt/atlas_local/chaozhong/data/aim/trio_pipeline:/run/inheritance \
lucianli123/marrvel-py python /run/inheritance/rename_VCFheader.py ${SAMPLE_P} ${SAMPLE_F} ${SAMPLE_M} /out/vcfheaders.txt

docker run -v $6:/out \
biocontainers/bcftools:v1.9-1-deb_cv1 \
bcftools reheader --samples /out/sample_ids.txt \
                  -o /out/${3}.joint2.vcf.gz \
                  /out/${3}.joint.vcf.gz

mv $6/${3}.joint2.vcf.gz $6/${3}.joint.vcf.gz
rm $6/${3}.joint.vcf.gz.tbi
tabix $6/${3}.joint.vcf.gz


echo "GATK De Novo Calling..."
/mnt/atlas_local/chaozhong/data/GATK/gatk-4.2.5.0/gatk VariantAnnotator \
-A PossibleDeNovo \
-R /mnt/atlas_local/chaozhong/data/bioref/ref_b37/hs37d5.fa \
--pedigree $7 \
-V /$6/${3}.joint.vcf.gz \
-O $6/inheritance/$3.DeNovo.g.vcf


#rm $6/inheritance/$3.vcf.gz
#rm $6/inheritance/$3.vcf.gz.tbi

echo "Check variants inheritance..."
docker run -v $6:/out -v $4:/run \
-v /mnt/atlas_local/chaozhong/data/aim/trio_pipeline:/run/inheritance \
lucianli123/marrvel-py python /run/inheritance/check_inheritance.GATK.py $3 /out/inheritance/$3.DeNovo.g.vcf hg19 ${SAMPLE_P} ${SAMPLE_F} ${SAMPLE_M}


# Extract patient VCF from joint VCF
#=======================================================
# TODOs
#=======================================================
echo "Extract proband VCF..."
docker run -v $6:/out \
biocontainers/bcftools:v1.9-1-deb_cv1 \
bcftools view -c1 -Oz -o /out/${3}.vcf.gz -s ${SAMPLE_P} /out/${3}.joint.vcf.gz


# Run marvel singleton pipeline
echo "Run AIM default pipeline..."
bash ${AIM_PL} $6/$3.vcf.gz $2 $3 $4 $5 $6 ${12}


# Prepare trio feature matrix
echo "Prepare trio feature matrix"
docker run -v $6:/out -v $4:/run \
-v /mnt/atlas_local/chaozhong/data/aim/trio_pipeline:/run/inheritance \
lucianli123/marrvel-py python \
/run/inheritance/merge_inheritance.py /out/rami-test/$3_scores.csv \
/out/final_matrix/$3.csv /out/inheritance/$3.inheritance.txt /out/inheritance/$3.trio.mtx.csv


# Make prediction
#=======================================================
# change model in predict_trio
# change features in predict_trio
#=======================================================
echo "Run trio model to predict risk score"
#docker run  -v $6:/out -v $4:/run \
#-v /houston_30t/chaozhong/aimarrvel_pipeline/trio_pipeline/predict_trio:/run/predict_trio \
#lucianli123/marrvel-py python /run/predict_trio/run_final.py $3

docker run  -v $6:/out -v $4:/run \
-v /mnt/atlas_local/chaozhong/data/aim/trio_pipeline/predict_trio:/run/predict_trio \
chaozhongliu/aimarrvel-trio-python python3.8 /run/predict_trio/run_final.py $3

docker run  -v $6:/out -v $4:/run \
-v /mnt/atlas_local/chaozhong/data/aim/trio_pipeline/predict_trio:/run/predict_trio \
chaozhongliu/aimarrvel-trio-python python3.8 /run/predict_trio/run_final_NDG.py $3


docker run \
-v $6:/out -v $4:/run \
-v /mnt/atlas_local/chaozhong/data/aim/trio_pipeline:/run/inheritance \
lucianli123/marrvel-py \
python /run/inheritance/merge_rm_trio.py $3

# 3 111686822   .   CA  C,CAA



