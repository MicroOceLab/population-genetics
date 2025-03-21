#!/usr/bin/env python3

import pandas as pd
import sys

def main():
    fpath = f"{sys.argv[1]}"
    sample_id = fpath.split("/")[-1]
    
    print(sample_id)

main()