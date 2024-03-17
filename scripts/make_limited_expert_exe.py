from make_limited_expert import make_limited_expert

import argparse

def argument_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--model-name",
        default=None,
        type=str,
    )
    parser.add_argument(
        "--language",
        default=None,
        type=str,
    )
    parser.add_argument(
        "--num-units",
        default=None,
        type=int,
    )
    return parser.parse_args()

args = argument_parser()

make_limited_expert(args.model_name, args.language, args.num_units)
