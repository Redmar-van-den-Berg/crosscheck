containers = {
        'debian': 'docker://debian:latest',
        'picard': 'docker://quay.io/biocontainers/picard:2.26.6--hdfd78af_0',
}

def get_input_files(wildcards):
    """ Return a list of the specified input files """
    return pep.sample_table.loc[wildcards.sample, 'files']

def get_picard_input_string(wildcards):
    return ' '.join(f'INPUT={x}' for x in get_input_files(wildcards))
