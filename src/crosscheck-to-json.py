#!/usr/bin/env python3

import argparse
import json

def get_header(fin):
    """ Skip fin forward, and return the header

        What remains in the file is the data lines
    """
    for line in fin:
        line = line.strip('\n')
        # Skip headers, and empty lines
        if line.startswith('#') or not line:
            continue
        # If we get to the first usefull line, we assume it is the header
        else:
            return line.strip('\n').split('\t')

def parse_crosscheck_file(fin):
    """ Parse the crosscheck file """
    data = list ()
    header = get_header(fin)
    for line in fin:
        # If it is an empty line
        if line == '\n':
            continue
        values = line.strip('\n').split('\t')
        row = {field: value for field, value in zip(header, values)}
        data.append(row)
    return data

def cleanup(row):
    """ Clean up the raw data from a single line from the crosscheck output

        For numbers, try to convert to int or float
        For files, remove the file:// prefix to get the exact path
    """
    remove = list()
    for field, value in row.items():
        # Store fields with empty values, to remove later. At this point value
        # is still a string, so "0" will not be removed
        if not value:
            remove.append(field)
        # Convert to int
        elif 'VALUE' in field:
            row[field] = int(value)
        # Convert to float
        elif 'LOD_SCORE' in field:
            row[field] = float(value)
        # Remove file:// prefix
        elif 'FILE' in field:
            if value.startswith('file://'):
                row[field] = value[7:]

    # Remove fields with empty values
    for field in remove:
        row.pop(field)

    return row

def main(args):
    
    with open(args.crosscheck) as fin:
        data = parse_crosscheck_file(fin)
    
    clean_data = [cleanup(row) for row in data]

    print(json.dumps(clean_data, indent=True))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('--crosscheck', required=True)
    arguments = parser.parse_args()
    main(arguments)
