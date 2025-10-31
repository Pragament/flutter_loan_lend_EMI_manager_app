#!/usr/bin/env python3
import sys


def fix_file(path):
    with open(path, 'r') as f:
        lines = f.readlines()

    # Find class start
    class_start = 0
    for i, line in enumerate(lines):
        if '_EmiDetailsPageState extends ConsumerState<EmiDetailsPage>' in line:
            class_start = i
            break

    # Find each method section
    methods = []
    current_method = []
    brace_count = 0
    in_method = False

    for line in lines[class_start:]:
        if line.strip().startswith('double _'):
            if current_method:
                methods.append('\n'.join(current_method))
                current_method = []
            in_method = True
            brace_count = 0

        if in_method:
            current_method.append(line.rstrip())
            brace_count += line.count('{') - line.count('}')
            if brace_count == 0 and current_method:
                methods.append('\n'.join(current_method))
                current_method = []
                in_method = False

    if current_method:
        methods.append('\n'.join(current_method))

    # Remove broken methods
    good_methods = [m for m in methods if not any(s in m for s in [
                                                  '_calculateTransactionBalance', '_calculateTotalPrincipalPaid', '_calculateCombinedBalance'])]

    # Find insert point
    insert_point = class_start
    for i, line in enumerate(lines[class_start:], class_start):
        if '@override' in line:
            insert_point = i - 1
            break

    # Reconstruct file
    new_lines = lines[:insert_point]
    new_lines.extend('\n' + m + '\n' for m in good_methods)
    new_lines.extend(lines[insert_point:])

    # Write file
    with open(path, 'w') as f:
        f.write(''.join(new_lines))
