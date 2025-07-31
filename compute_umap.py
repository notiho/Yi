import sys
import numpy as np
from pathlib import Path
from umap

embeddings_filename = Path(sys.argv[1])

embeddings = np.load(embeddings_filename)

umap_reducer5 = umap.UMAP(
    n_neighbors = 15,
    n_components = 5,
    min_dist = 0.0,
    metric = "cosine",
    random_state = 42
)

embeddings_dimensionality_reduced5 = umap_reducer5.fit_transform(embeddings)

input("Press enter to start writing to file.")
np.save(f"{embeddings_filename.stem}_dimensionality_reduced5.npy", embeddings_dimensionality_reduced5)

umap_reducer2 = umap.UMAP(
    n_neighbors = 15,
    n_components = 2,
    min_dist = 0.0,
    metric = "cosine",
    random_state = 42
)

embeddings_dimensionality_reduced2 = umap_reducer2.fit_transform(embeddings)

input("Press enter to start writing to file.")
np.save(f"{embeddings_filename.stem}_dimensionality_reduced2.npy", embeddings_dimensionality_reduced2)

