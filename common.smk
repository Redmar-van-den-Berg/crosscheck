containers = {
        'python3': 'docker://python:latest',
        'picard': 'docker://quay.io/biocontainers/picard:2.26.6--hdfd78af_0',
        'array-as-vcf': 'docker://quay.io/biocontainers/mulled-v2-cebd7a0eda25340aaa510eadd04701e136feb076:441826efb09a6cf80e9b36a3f50867b1a3661bed-0',
}

def get_input_files(wildcards):
    """ Return a list of the specified input files """
    return pep.sample_table.loc[wildcards.sample, 'files']

def get_picard_input_string(wildcards):
    return ' '.join(f'INPUT={x}' for x in get_input_files(wildcards))

def samples_with_array():
    """ Return samples that have an array file """
    samples = list()

    for sample in pep.sample_table['sample_name']:
        # Get the array from the pep sample table
        array = pep.sample_table.loc[sample, 'array']

        # If an array is specified, it will be a string
        # (otherwise, it will be float('nan')
        if isinstance(array, str):
            samples.append(sample)

    return samples

def get_array(wildcards):
    """ Return the array beloning to wildcards.sample

    This function is only called for samples where an array is present, via the
    samples_with_array function in the all rule
    """
    return pep.sample_table.loc[wildcards.sample, 'array']
