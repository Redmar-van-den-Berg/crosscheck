pepfile: config['pepfile']
config = pep.config['crosscheck']
include: 'common.smk'


rule all:
    input:
        crosscheck = expand('{sample}/crosscheck.txt', sample=pep.sample_table["sample_name"])

rule picard_crosscheck:
    input:
        files = get_input_files,
        haplotype_map = config['haplotype_map']
    params:
        get_picard_input_string
    output:
        '{sample}/crosscheck.txt'
    log:
        'log/{sample}_crosscheck.txt'
    container:
        containers['picard']
    shell: """
        picard CrosscheckFingerprints \
            {params} \
            HAPLOTYPE_MAP={input.haplotype_map} \
            OUTPUT={output} 2> {log}
    """
