# AIRMONITORSOCIAL

Local, multi-model analysis of public political posts: how each party frames its messages, whom it
criticises, which issues it talks about and how, and where several accounts push the same message.
Everything runs on your own PC (Ollama + your GPU); no post leaves the machine.

## Start

1. Install [Ollama](https://ollama.com) and Python 3.10+.
2. Double-click **`setup.bat`** (add `gpu` for the GPU sentiment tool: `setup.bat gpu`, about 3 GB).
3. Pull the models your profile needs; `python monitor.py doctor` lists any that are missing, e.g.
   `ollama pull qwen3:8b`, `ollama pull bge-m3`.
4. Optional, for speed: `tune_ollama.bat` (12 GB GPU) or `tune_ollama.bat 8` (RTX 4090), then restart Ollama.
5. Double-click **`dashboard.bat`**. In **▶ Run & system**, upload your posts, pick models and tools, press
   **Start analysis**. The results appear in the other tabs.

Without the dashboard: `analyze.bat data\my_posts.jsonl`, then read `reports\my_posts\party_framing.md`.

## Your data

A `.jsonl` file (one post per line) or a `.json` array. Only a text field is required:

```json
{"id": "123", "timestamp": "2026-11-01T08:00:00Z", "author": "@some_account", "text": "..."}
```

- Text: `text`, `full_text`, `content`, `body`, `message` or `caption`. Id: `id`, `post_id`, `tweet_id` or `url`.
- Author: `author`, `username`, `screen_name`, `user`, `account` or `handle`. Time: `timestamp`, `created_at`, `date`, …
- **Parties:** a post's `party` field if it has one, otherwise its author is looked up in `config/parties.yaml`
  (accounts and aliases per party). The included parties are fictional and only match `data/sample_posts.jsonl`.

## What it finds

| Tool | What it adds |
|---|---|
| `narrative` | the 3 keys from `src/ai_analyzer.py` (category, rhetorical strategy, 10-word intent) from **every model in the profile**; majority vote, a bigger judge model settles split votes; agreement statistics and per-model label counts (to spot a model that leans) |
| `targets` | who each post criticises / praises / addresses; party names, aliases and accounts are mapped to parties ("who criticises whom") |
| `sentiment` | negative / neutral / positive, multilingual transformer on the GPU (`setup.bat gpu`) |
| `embeddings` | meaning vectors (bge-m3, multilingual) used by the next two |
| `coordination` | copy-pasted or near-identical posts from different accounts within 48 h |
| `clusters` | issues (topics) named by a local model, and each party's frame per issue |
| `language`, `surface` | language; hashtags, mentions, links |
| `party_framing` | per party: label shares vs all other posts with significance tests, distinctive words, targets, hashtags, tone, issues, and a written profile; plus a comparison of all parties |
| `keyword_watch` | example plugin: watch-list keywords per party |

Outputs per dataset in `reports/<dataset>/`: `party_framing.md` (readable report), `corpus.json`,
`processed_narratives.json` (one record per post). `reports/processed_narratives.json` collects the posts of
every dataset (the staging file from the original spec). Every model answer is cached in
`reports/cache.sqlite`: a re-run, or adding a model, only does the new work.

## Hardware profiles (`config/settings.yaml`)

`profile: auto` picks by GPU memory. Change the models freely; `python monitor.py doctor` shows what is installed.

| Profile | For | Narrative models | Judge | Parallel requests |
|---|---|---|---|---|
| `cpu_only` | no NVIDIA GPU | qwen3:4b, gemma3:4b | none | 2 |
| `gpu_12gb` | RTX 3060 12GB / 4070 / 5070 (this PC) | qwen3:8b, gemma3:12b | qwen3:14b | 4 |
| `gpu_24gb` | RTX 3090 / **4090**, 64–128 GB RAM | qwen3:14b, gemma3:27b, mistral-small3.2:24b | qwen3:32b | 8 |
| `gpu_24gb_max` | 4090 + 128 GB RAM (choose it explicitly) | the three above + qwen3:32b | llama3.3:70b (split across GPU and RAM; slow, only for split votes) | 8 |

Models from different families (Qwen, Gemma, Mistral, Llama) are used on purpose: they make different
mistakes, so the vote cancels more of them out. Models run one after another over all posts so the GPU never
swaps models per post.

## Adding libraries and tools

- **Libraries:** add them to `requirements/my_libraries.txt` and run `setup.bat` again.
- **Tools:** drop a `.py` file into `plugins/` (copy `plugins/keyword_watch.py`), add its name to `tools:` in
  `config/settings.yaml`. It appears in the dashboard and its results in the Posts table and the report.
  See `plugins/README.md` for what a tool can use (models, embeddings, cache, other tools' results).

## Command line

```
python monitor.py doctor                         hardware, profile, Ollama, models, tools
python monitor.py run                            analyse the input in settings.yaml
python monitor.py run --input data\x.jsonl --models qwen3:8b,gemma3:12b --judge qwen3:14b --tools narrative,party_framing
python monitor.py run --profile gpu_24gb_max     choose a profile
python src\ai_analyzer.py --text "..." --no-save single-model labelling of one text (the original script)
```

## Limits

- Labels and written profiles come from AI models and can be wrong. The Models tab shows how often the models
  agreed; the written profiles are generated from the numbers shown beside them and can overstate a
  difference, so read them with the numbers. Spot-check posts before relying on the results.
- A party profile describes only the posts in your dataset from the accounts you mapped to that party.
- Posts can contain text aimed at the classifier ("label this post…"); they are flagged `injection_suspected`.
- Coordination groups are leads, not proof: campaign copy and shared talking points look the same as bot networks.
- If `setup.bat gpu` fails with a long-path error, keep the project in a short folder or enable Windows long paths.
