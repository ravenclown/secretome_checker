configfile:"config.yaml"

rule all:
    input:
      expand("{sample}/processed_entries.fasta", sample=config["sample"]),
      expand("{sample}/region_output.gff3", sample=config["sample"]),
      expand("{sample}/output.gff3", sample=config["sample"]),
      expand("{sample}/prediction_results.txt", sample=config["sample"])

rule chr2mRNA2prot:
    input:
      fas="{sample}.fasta"
      gff="{sample}.gff"
    output:
      {sample}_prot.fasta
    params:
      sample = "{sample}"
    shell:
       "awk '$3=="mRNA"' {input.gff} > {params.sample}_annot_mRNA.gff3 && \
       awk '{print $1":"$4"-"$5}' {params.sample}_annot_mRNA.gff3 > {params.sample}_mRNA.regions && \
       samtools faidx {input.fas} -r {params.sample}_mRNA.regions > {params.sample}_mRNA.fasta && \
       transeq -sequence {params.sample}_mRNA.fasta -outseq {output}"

rule signalp6:
    input:
      "{sample}_mRNA.fasta"
    output:
      "processed_entries.fasta",
      "region_output.gff3",
      "output.gff3",
      "prediction_results.txt"
    params:
      sample = "{sample}"
    shell:
      "mkdir -p {params.sample} && \
      signalp6 -ff {input} -od {params.sample}"
