import sys
import numpy as np
from pathlib import Path
from umap

embeddings_filename = Path(sys.argv[1])
n_components = int(sys.argv[2])

embeddings = np.load(embeddings_filename)

umap_reducer = umap.UMAP(
    n_neighbors = 15,
    n_components = n_components,
    min_dist = 0.0,
    metric = "cosine",
    random_state = 42
)

embeddings_dimensionality_reduced = umap_reducer.fit_transform(embeddings)

input("Press enter to start writing to file.")
np.save(f"{embeddings_filename.stem}_dimensionality_reduced{n_components}.npy", embeddings_dimensionality_reduced)

