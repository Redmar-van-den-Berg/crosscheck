pepfile: config['pepfile']
config = pep.config['crosscheck']
include: 'common.smk'


rule all:
    input:
        crosscheck = expand('{sample}/crosscheck.txt', sample=pep.sample_table['sample_name']),
        json = expand('{sample}/crosscheck.json', sample=pep.sample_table['sample_name']),
        array = expand('{sample}/array.vcf', sample=samples_with_array()),

rule convert:
    """ Convert the array to VCF format """
    input:
        array = get_array,
        lookup = config.get('array_lookup', '')
    output:
        '{sample}/array.raw.vcf'
    log:
        'log/{sample}_convert_array.txt'
    container:
        containers['array-as-vcf']
    shell: """
        aav --path {input.array} \
            --sample-name {wildcards.sample} \
            --lookup-table {input.lookup} \
            --no-ensembl-lookup \
            --chr-prefix chr \
            2> {log} > {output}
    """

rule update_array_vcf_header:
    """ Update the header of the array VCF with the headers of the sample VCF
    file. Picard requires the headers to match (or at least, include the same
    CONTIG fields).
    """
    input:
        array_vcf = rules.convert.output,
        # Just pick a random file as sequence dictionary, since SAM, BAM, VCF,
        # BCF are all supported
        dictionary = get_input_file
    output:
        '{sample}/array.vcf'
    log:
        'log/{sample}_update_header.txt'
    container:
        containers['picard']
    shell: """
        picard UpdateVcfSequenceDictionary \
            INPUT={input.array_vcf} \
            SEQUENCE_DICTIONARY={input.dictionary} \
            OUTPUT={output} 2> {log}
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
