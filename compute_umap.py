import numpy as np
from cuml.manifold import UMAP

embeddings = np.load("embeddings.npy")

umap_reducer5 = UMAP(
    n_neighbors = 15,
    n_components = 5,
    min_dist = 0.0,
    metric = "cosine",
    random_state = 42
)

embeddings_dimensionality_reduced5 = umap_reducer5.fit_transform(embeddings)

input("Press enter to start writing to file.")
np.save("embeddings_dimensionality_reduced5.npy", embeddings_dimensionality_reduced5)

umap_reducer2 = UMAP(
    n_neighbors = 15,
    n_components = 2,
    min_dist = 0.0,
    metric = "cosine",
    random_state = 42
)

embeddings_dimensionality_reduced2 = umap_reducer2.fit_transform(embeddings)

input("Press enter to start writing to file.")
np.save("embeddings_dimensionality_reduced2.npy", embeddings_dimensionality_reduced2)

