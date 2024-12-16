library(tidyverse)
library(reticulate)

samples <- read_csv("samples.csv")
samples <- samples %>% mutate(index = index + 1) %>%
  mutate(title = str_split_i(kr_third, "-", 1),
         time_period = str_split_i(kr_third, "-", 2),
         authord = str_split_i(kr_third, "-", 3))
cluster_assignments <- read_csv("cluster_assignments.csv")
cluster_assignments <- cluster_assignments %>% mutate(index = index + 1)
samples <- inner_join(samples, cluster_assignments)
corpus_statistics <- read.csv("corpus_statistics.csv")
dynasty_times <- read_csv("dynasty_times.csv")

np <- import("numpy")
umap2 <- np$load("embeddings_dimensionality_reduced2.npy")
colnames(umap2) <- c("x", "y")

# Section 2
sum(corpus_statistics %>% 
  group_by(filename) %>%
  slice_head(n = 1) %>%
  pull(total_length))

n_distinct(corpus_statistics$kr_third)
n_distinct(corpus_statistics$filename)

corpus_statistics %>% 
  group_by(character) %>%
  summarise(count = sum(count)) %>%
  slice_max(count, n = 20)

round(100 * 913363 / 113779256, 2)

# Corpus by genre & time
corpus_statistics %>%
  group_by(filename) %>%
  slice_head(n = 1) %>%
  group_by(kr_second) %>%
  summarise(n_chars = sum(total_length))

corpus_statistics %>%
  group_by(filename) %>%
  slice_head(n = 1) %>%
  mutate(dynasty = str_split_i(kr_third, "-", 2)) %>%
  left_join(rownames_to_column(dynasty_times, var = "index"),
            by = join_by("dynasty")) %>%
  mutate(index = as.numeric(index)) %>%
  group_by(dynasty_normalized) %>%
  summarise(num_chars = round(sum(total_length) / 1000000, 1),
            start = first(start),
            end = first(end),
            index = first(index)) %>%
  arrange(index) %>%
  mutate(name = paste0(
    dynasty_normalized, " (",
    start, "-", end, ")")) %>%
  select(name, num_chars)

# yis_per_genre <- corpus_statistics %>%
  filter(character == "一") %>%
  group_by(kr_second) %>%
  summarise(total_length = sum(total_length), yi_count = sum(count)) %>%
  mutate(relative = 100 * yi_count / total_length) %>%
  arrange(desc(relative))
yis_per_genre
mean(yis_per_genre$relative)
sd(yis_per_genre$relative)

yis_per_title <- corpus_statistics %>%
  filter(character == "一") %>%
  group_by(kr_third) %>%
  summarise(total_length = sum(total_length), yi_count = sum(count)) %>%
  mutate(relative = 100 * yi_count / total_length) %>%
  arrange(desc(relative))
yis_per_title
yis_per_title %>% slice_min(relative)
mean(yis_per_title$relative)
sd(yis_per_title$relative)

# Example of 一切
quantile(umap2[, 1], c(0.001, 0.999))
quantile(umap2[, 2], c(0.001, 0.999))

umap2_highlight <- function(highlight_indices, highlight_red_indices,
                            highlight_green_indices) {
  rst <- ggplot() +
    geom_point(aes(x = x, y = y), data = umap2, shape = ".", col = "grey") +
    geom_point(aes(x = x, y = y), data = umap2[highlight_indices, ], alpha = 0.1) +
    geom_point(aes(x = x, y = y), data = umap2[highlight_red_indices, , drop = F], alpha = 0.3, color = "red") +
    theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank()) +
    xlab("") + ylab("") +
    coord_equal() +
    theme(legend.position = "none")
  
  if (!missing(highlight_green_indices)) {
    rst <- rst + geom_point(aes(x = x, y = y), data = umap2[highlight_green_indices, , drop = F], alpha = 0.3, color = "green")
  }
  rst
}

zhi_yi_qie_bing_umap <- umap2_highlight(samples %>%
                                          filter(startsWith(context_right, "切") & !(endsWith(context_left, "治") & startsWith(context_right, "切病"))) %>% pull(index),
                                        samples %>%
                                          filter(startsWith(context_right, "切病") & endsWith(context_left, "治")) %>% pull(index)) +
  scale_x_continuous(limits = c(-14, 15.5)) +
  scale_y_continuous(limits = c(-13, 15))
ggsave("zhi_yi_qie_bing_umap2.png", plot = zhi_yi_qie_bing_umap, width=10, height=10)

6571 / nrow(umap2)

yi_ren_umap <- umap2_highlight(samples %>%
                  filter(grepl("^人", context_right)) %>% pull(index),
                samples %>%
                  filter(cluster_index == 28) %>% pull(index),
                samples %>% 
                  filter(cluster_index == 44) %>% pull(index)) +
  scale_x_continuous(limits = c(-14, 15.5)) +
  scale_y_continuous(limits = c(-13, 15))
ggsave("yi_ren_umap2.png", plot = yi_ren_umap, width=10, height=10)


yi_x_ren_umap <- umap2_highlight(samples %>%
                  filter(grepl("^子", context_right)) %>% pull(index),
                samples %>%
                  filter(cluster_index == 44) %>% pull(index)) +
  scale_x_continuous(limits = c(-14, 15.5)) +
  scale_y_continuous(limits = c(-13, 15))
ggsave("yi_x_ren_umap2.png", plot = yi_x_ren_umap, width=10, height=10)


umap2_highlight(samples %>% filter(grepl("^[日夜朝夕旦]", context_right)) %>% pull(index),
                samples %>% filter(cluster_index %in% c(321, 492, 869)) %>% pull(index)) +
  scale_x_continuous(limits = c(-14, 15.5)) +
  scale_y_continuous(limits = c(-13, 15))

kwic <- function(indices) {
  samples[indices, ] %>%
    mutate(context_left = substr(context_left, str_length(context_left) - 20, str_length(context_left)),
           context_right = substr(context_right, 1, 20),
           filename = str_split_i(filename, "/", -1)) %>%
    select(filename, cluster_index, context_left, context_right)
}

which.min(umap2[samples %>% filter(startsWith(context_right, "切")) %>% pull(index), 2])
kwic((samples %>% filter(startsWith(context_right, "切")))[801, ] %>% pull(index))

# Some basic statistics about the clustering
max(cluster_assignments$cluster_index)
cluster_assignments %>% count(cluster_index == -1)

# Section 3
# Size of clusters:
cluster_counts <- cluster_assignments %>%
  count(cluster_index) %>%
  filter(cluster_index != -1) %>%
  pull(n)
quantile(cluster_counts, 0.5)
mean(cluster_counts)
sd(cluster_counts)
max(cluster_counts)
sum(cluster_counts > 10000)
sum(cluster_counts > 1000)
sum(cluster_counts > 100)

samples %>%
  filter(cluster_index == 0 & probability == 1) %>%
  count(kr_second) %>%
  mutate(percentage = n / sum(n))

samples %>% 
  filter(cluster_index != -1) %>%
  group_by(cluster_index) %>%
  count(kr_second) %>%
  mutate(percentage = n / sum(n)) %>%
  summarise(highest_percentage = max(percentage)) %>%
  count(highest_percentage >= 0.99) %>%
  mutate(percentage = n / sum(n))

samples %>% 
  filter(cluster_index != -1) %>%
  group_by(cluster_index) %>%
  count(time_period) %>%
  mutate(percentage = n / sum(n)) %>%
  summarise(highest_percentage = max(percentage)) %>%
  count(highest_percentage >= 0.99) %>%
  mutate(percentage = n / sum(n))

# sample 50 clusters over the range of cluster sizes
set.seed(1234)
data.frame(n = cluster_counts) %>%
  rownames_to_column(var = "index") %>%
  mutate(size1 = n >= 1000,
         size2 = n < 1000 & n >= 100,
         size3 = n < 100 & n >= 50,
         size4 = n < 50) %>%
  group_by(size1, size2, size3, size4) %>%
  sample_n(25) %>%
  ungroup() %>%
  select(index) %>%
  mutate(index = as.integer(index) - 1) %>%
  arrange(index) %>%
  write_csv("clusters_for_quality_check.csv")


# 一x一y
samples %>% 
  filter(cluster_index != -1 & probability == 1) %>%
  mutate(is_yi_x_yi_y = grepl("[^一].一.$", context_left) |
           grepl("^.一.[^一]", context_right)) %>%
  group_by(cluster_index) %>%
  summarise(target_count = sum(is_yi_x_yi_y),
            total = n()) %>%
  mutate(prop = target_count / total) %>%
  filter(target_count >= 10 & prop >= 0.75) %>%
  arrange(desc(prop)) %>%
  print(n = 40)

samples %>% filter(cluster_index == 1310) %>% count(kr_second)

samples %>% 
  filter(cluster_index == 230) %>%
  mutate(is_zhi_wei_dao = startsWith(context_right, "陽之謂道"),
         has_quote = grepl("[曰云].{0,5}$", context_left)) %>%
  count(is_zhi_wei_dao, has_quote)

samples %>% 
  filter(cluster_index == 321) %>%
  mutate(has_qi_suo_you_lai = grepl("^(朝一)?夕之故也?其所由來", context_right)) %>%
  filter(has_qi_suo_you_lai) %>%
  select(context_right)

16 / 199

samples %>% 
  filter(cluster_index == 321) %>%
  filter(grepl("^(朝一)?夕之", context_right)) %>%
  mutate(after_zhi = str_split_i(context_right, "之", 2)) %>%
  count(if_else(startsWith(after_zhi, "所"), substr(after_zhi, 1, 2),
                substr(after_zhi, 1, 1))) %>%
  arrange(desc(n)) %>%
  mutate(total = sum(n))

145 / 199

samples %>% 
  filter(cluster_index == 321) %>%
  count(if_else(endsWith(context_left, "一朝") | endsWith(context_left, "一旦"),
                substr(context_left, str_length(context_left) - 2, str_length(context_left) - 2),
                substr(context_left, str_length(context_left), str_length(context_left)))) %>%
  arrange(desc(n))

147 / 199
40 / 199

samples %>% 
  filter(cluster_index == 492) %>%
  mutate(is_yi_ri_yi_ye = (startsWith(context_right, "日一夜") | startsWith(context_right, "日一夕")) |
           endsWith(context_left, "一日") & (startsWith(context_right, "夜") | startsWith(context_right, "夕"))) %>%
  count(is_yi_ri_yi_ye)

95 / 113

samples %>%
  filter(cluster_index == 127) %>%
  count(if_else(startsWith(context_right, "大") | startsWith(context_right, "小"),
                substr(context_right, 1, 2),
                substr(context_right, 1, 1))) %>%
  mutate(prop = n / sum(n)) %>%
  arrange(desc(n)) %>%
  print(n = 30)
114 / 649


samples %>%
  filter(cluster_index == 127) %>%
  count(grepl("曰", substr(context_right, 1, 10)))
451 / 649

samples %>%
  filter(cluster_index == 127) %>%
  count(grepl("[髙高]", substr(context_right, 1, 10)))
65 / 649

samples %>%
  filter(cluster_index == 127) %>%
  count(substr(context_left, str_length(context_left), str_length(context_left))) %>%
  mutate(prop = n / sum(n)) %>%
  arrange(desc(n)) %>%
  print(n = 30)

samples %>%
  filter(cluster_index == 127) %>%
  count(grepl("[年]", substr(context_left, str_length(context_left) - 10, str_length(context_left))))
311 / 649

samples %>%
  filter(cluster_index == 127) %>%
  count(grepl("帝", substr(context_left, str_length(context_left) - 10, str_length(context_left))))

samples %>%
  filter(cluster_index == 127) %>%
  count(kr_third)

samples %>%
  filter(cluster_index == 28) %>%
  count(substr(context_right, 1, 1))

samples %>%
  filter(cluster_index == 28) %>%
  count(substr(context_left, str_length(context_left), str_length(context_left))) %>%
  mutate(prop = n / sum(n)) %>%
  arrange(desc(n))

samples %>%
  filter(cluster_index == 28) %>%
  count(grepl("[云曰]", substr(context_right, 1, 10))) %>%
  mutate(prop = n / sum(n)) %>%
  arrange(desc(n))

samples %>%
  filter(cluster_index == 28) %>%
  count(substr(context_left, str_length(context_left) - 1, str_length(context_left))) %>%
  mutate(prop = n / sum(n)) %>%
  arrange(desc(n))

samples %>%
  filter(cluster_index == 28) %>%
  count(kr_second) %>%
  mutate(prop = n / sum(n)) %>%
  arrange(desc(n))

samples %>%
  filter(cluster_index == 44) %>%
  count(substr(context_right, 1, 2)) %>%
  mutate(prop = n / sum(n)) %>%
  arrange(desc(n))

samples %>%
  filter(cluster_index == 44) %>%
  count(kr_second) %>%
  mutate(prop = n / sum(n)) %>%
  arrange(desc(n))

samples %>% 
  filter(cluster_index != -1 & probability == 1) %>%
  group_by(cluster_index) %>%
  summarise(target_num = sum(time_period == "清" & kr_second == "天文算法類"),
            size = n()) %>%
  filter(target_num / size >= 0.99) %>%
  arrange(desc(target_num)) %>%
  print(n = 100)

samples %>%
  filter(endsWith(context_left, "每") & startsWith(context_right, "邊"))

samples %>%
  filter(cluster_index == 137) %>%
  count(substr(context_right, 1, 1))

kwic(samples %>%
       filter(cluster_index == 137 & kr_third != "御製數理精薀-清-聖祖玄燁") %>% pull(index))

