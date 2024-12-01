import glob
import regex
from multiprocessing import Pool
import tqdm
from collections import defaultdict, Counter

non_hanzi_regex = regex.compile(r"\P{sc=Han}")
def only_hanzi(s):
	return regex.sub(non_hanzi_regex, "", s)

kr_metadata = defaultdict(str)

for metadata_filename in glob.glob("KR-Catalog-master/KR/*.txt"):
	with open(metadata_filename) as infile:
		lines = infile.readlines()
		for l in lines:
			if regex.match(r"\*{1,3} ", l):
				parts = l.split()
				kr_metadata[parts[1]] = parts[-1]

def process_file(filename):
	with open(filename) as raw:
		text = raw.read()
	
	main_text = ""
	in_comment = False
	
	for l in text.split("\n"):
		if l.startswith("#"):
			continue
		else:
			for c in l:
				if c == "(":
					in_comment = True
				elif c == ")":
					in_comment = False
				else:
					if in_comment:
						pass
					else:
						main_text += only_hanzi(c)
	if len(main_text) < 20:
		return None
	
	return [filename, main_text]

filenames = glob.glob("./corpus/*/*.txt")

with Pool(40) as pool:
	rsts = list(tqdm.tqdm(pool.imap_unordered(process_file, filenames, chunksize = 4), total = len(filenames)))

rsts = [r for r in rsts if r != None]
rsts.sort(key = lambda x: x[0])

with open("corpus_statistics.csv", "w") as outfile:
	outfile.write("filename,kr_first,kr_second,kr_third,total_length,character,count\n")
	
	index = 0
	
	for filename, text in tqdm.tqdm(rsts):
		counts = Counter(text)
		kr_number = filename.split("/")[-1].split("_")[0]
		
		for c, n in counts.most_common():
			outfile.write(",".join((filename,
				kr_metadata[kr_number[:3]],
				kr_metadata[kr_number[:4]],
				kr_metadata[kr_number],
				str(len(text)),
				c,
				str(n))) + "\n")
