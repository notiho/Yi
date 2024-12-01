import numpy as np
import tqdm
from cuml.cluster import hdbscan
from collections import Counter

embeddings = np.load("embeddings_dimensionality_reduced5.npy")

clusterer = hdbscan.HDBSCAN(
	min_cluster_size = 5,
	metric = "euclidean",
	cluster_selection_method = "eom",
	prediction_data = False
)

clusterer.fit(embeddings)

hdbscan_labels = clusterer.labels_
hdbscan_probabilities = clusterer.probabilities_

max_cluster_index = np.max(hdbscan_labels)

print(f"Got {max_cluster_index + 1} clusters, outliers: {np.sum(hdbscan_labels == -1) / len(embeddings)}")

cluster_counts = Counter(hdbscan_labels)
cluster_counts_sorted = [(original_index, count) for original_index, count in cluster_counts.most_common() if original_index != -1]
cluster_counts_sorted.sort(key = lambda xn: xn[1] * (max_cluster_index + 1) + xn[0], reverse = True)
cluster_counts_sorted = [x for x, _ in cluster_counts_sorted]

input("Press enter to start writing to file.")

with open("cluster_assignments.csv", "w") as assignments_outfile:
	assignments_outfile.write("index,cluster_index,probability,cluster_index_raw\n")
	for i, (label, probability) in enumerate(zip(hdbscan_labels, hdbscan_probabilities)):
		assignments_outfile.write(f"{i},{cluster_counts_sorted.index(label) if label != -1 else -1},{probability},{label}\n")

