import sys
import pandas as pd
from sklearn.metrics import adjusted_rand_score

def main():
    if len(sys.argv) != 3:
        print("Usage: python compare_clusters.py file1.csv file2.csv")
        sys.exit(1)

    file1, file2 = sys.argv[1], sys.argv[2]

    # Load CSV files
    df1 = pd.read_csv(file1)
    df2 = pd.read_csv(file2)

    # Ensure they have the same indices
    if not all(df1['index'] == df2['index']):
        print("Error: 'index' columns do not match.")
        sys.exit(1)

    # Extract cluster indices
    labels1 = df1['cluster_index']
    labels2 = df2['cluster_index']

    # Compute ARI
    ari = adjusted_rand_score(labels1, labels2)

    print(f"Adjusted Rand Index: {ari:.6f}")

if __name__ == "__main__":
    main()
