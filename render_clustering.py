import sys
import json
import numpy as np
from pathlib import Path
from collections import Counter
import tqdm

data = []
embeddings_filename = Path(sys.argv[1])

cluster_counts = Counter()

with open(f"{embeddings_filename.stem}_cluster_assignments.csv") as infile:
	lines = infile.readlines()
	for l in lines[1:]:
		parts = l.split(",")
		data.append([int(parts[1]), float(parts[2])])

num_clusters = max(i[0] for i in data) + 1

with open("samples.csv") as infile:
	lines = infile.readlines()
	for i, l in enumerate(lines[1:]):
		parts = l.strip().split(",")
		data[i].extend(parts[3:])
		data[i][4] = "-".join(x[:10] for x in data[i][4].split("-"))
		data[i][5] = data[i][5][-20:]
		data[i][6] = data[i][6][:20]
		data[i].append(parts[1].split("/")[-1].split(".")[0])

data = [i for i in data if i[0] != -1]


with open("viewer.html") as infile:
	text = infile.read().replace("!!DATA!!", json.dumps(data))

with open(f"{embeddings_filename.stem}_viewer_rendered.html", "w") as outfile:
	outfile.write(text)
