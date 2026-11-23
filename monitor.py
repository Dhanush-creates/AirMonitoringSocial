#!/usr/bin/env python3
"""AIRMONITORSOCIAL command line.

    python monitor.py doctor                      check hardware, Ollama, models and tools
    python monitor.py run                         analyse the dataset in config/settings.yaml
    python monitor.py run --input data/x.jsonl    analyse another dataset
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "src"))

from airmonitor.cli import main  # noqa: E402

if __name__ == "__main__":
    sys.exit(main())
