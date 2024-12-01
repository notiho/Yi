import tqdm
import numpy as np
from transformers import AutoTokenizer, BertForMaskedLM
import torch

tokenizer = AutoTokenizer.from_pretrained("Jihuai/bert-ancient-chinese")
model = BertForMaskedLM.from_pretrained("Jihuai/bert-ancient-chinese")

device = "cuda:0" if torch.cuda.is_available() else "cpu"
print(f"Using device: {device}")

model.to(device)
model.eval()

hidden_size = model.config.hidden_size
num_layers = model.config.num_hidden_layers
max_position_embeddings = model.config.max_position_embeddings

print(f"Hidden size: {hidden_size}, num_layers: {num_layers}, max_position_embeddings: {max_position_embeddings}")

targets = []
with open("samples.csv") as infile:
	targets = infile.readlines()[1:]

targets = [t.strip().split(",") for t in targets]

embeddings = []

for index,filename,index_in_file,kr_first,kr_second,kr_third,context_left,context_right in tqdm.tqdm(targets):
	inputs = tokenizer(["".join((context_left, "一", context_right))],
		return_tensors="pt", padding=True).to(device)
	
	assert(len(context_left) + len(context_right) + 1 <= max_position_embeddings - 2)
	
	with torch.no_grad():
		hidden = model(**inputs, output_hidden_states = True).hidden_states
		embeddings.append(hidden[9][0, 1 + len(context_left)].detach().cpu().numpy())

input("Press enter to start writing to file.")

embeddings = np.array(embeddings)
np.save("embeddings.npy", embeddings)
