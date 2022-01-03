pepfile: config['pepfile']
config = pep.config['crosscheck']
include: 'common.smk'


rule all:
    input:
        crosscheck = expand('{sample}/crosscheck.txt', sample=pep.sample_table['sample_name']),
        json = expand('{sample}/crosscheck.json', sample=pep.sample_table['sample_name']),
        array = expand('{sample}/array.vcf.gz', sample=samples_with_array()),

rule convert:
    input:
        array = get_array
    output:
        '{sample}/array.vcf.gz'
    log:
        'log/{sample}_convert_array.txt'
    singularity:
        containers['array-as-vcf']
    shell: """
        aav -p {input.array} \
            | bgzip -c > {output} && tabix -p vcf {output}"
    """

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

rule crosscheck_to_json:
    input:
        crosscheck = rules.picard_crosscheck.output,
        to_json = srcdir('src/crosscheck-to-json.py')
    output:
        '{sample}/crosscheck.json'
    log:
        'log/{sample}_crosscheck_to_json.txt'
    container:
        containers['python3']
    shell: """
        python {input.to_json} \
            --crosscheck {input.crosscheck} \
            > {output} 2>{log}
    """
