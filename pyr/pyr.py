#!/usr/local/bin/python3

import json, re, sys, argparse, os

with open(os.path.join(os.path.dirname(__file__), 'lib.py'), 'r') as f:
    exec(f.read())

parser = argparse.ArgumentParser(description="Manipulate data using ramda functions")
parser.add_argument('-j, --json', dest='json', action='store_true', help="process input as json")
parser.add_argument('-l, --line', dest='line', action='store_true', help="process input line by line")
parser.add_argument('expression')

args = parser.parse_args()

fn = eval("lambda x: {}".format(args.expression))

if args.json:
  input = json.loads(sys.stdin.read())
else:
  input = sys.stdin.read().strip().split('\n')

if args.line:
  result = (fn(x) for x in input)
else:
  result = fn(input)

if args.json:
  print(json.dumps(result))
elif hasattr(result, '__iter__'):
  print('\n'.join(map(str, result)))
else:
  print(result)
