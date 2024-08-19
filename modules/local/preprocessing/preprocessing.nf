process PREPROCESSING {
    tag "$familyId"
    label 'process_low'
 
    conda (params.enable_conda ? "bioconda::python-nextflow=0.8" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python-nextflow:0.8--pyhdfd78af_0':
        'biocontainers/python-nextflow:0.8--pyhdfd78af_0' }"

    input: 
    tuple  val(familyId), val(fmeta), val(samples) , path(vcfs)

    output:
    tuple val(familyId), path("*.DEL.vcf"), emit: vcfdel
    tuple val(familyId), path("*.DUP.vcf"), emit: vcfdup
    tuple val(familyId), path("*.DEL.bed"), emit: beddel
    tuple val(familyId), path("*.DUP.bed"), emit: beddup
    tuple val(familyId), path("*.mod.vcf"), emit: vcfmod
    path "ploidy-table.tsv",                emit: ploidy
    path "versions.yml",                    emit: versions 
        
    script:
    def sample_ids = samples.join(' ')
    """
    python ${moduleDir}/bin/sample_preprocessing.py --sample_id $sample_ids --path $vcfs

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python ${moduleDir}/bin/sample_preprocessing: \$(python sample_preprocessing.py --version | sed 's/sample_preprocessing.py version//')
    END_VERSIONS
    
    """
    
}
