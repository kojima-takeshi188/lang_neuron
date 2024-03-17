# On the Multilingual Ability of Decoder-based Pre-trained Language Models: Finding and Controlling Language-Specific Neurons

This is the official implementation of `On the Multilingual Ability of Decoder-based Pre-trained Language Models: Finding and Controlling Language-Specific Neurons` (Accepted at NAACL 2024).

The paper will be available soon.

## Original Source Code
```
git clone https://github.com/apple/ml-selfcond
git checkout c5e09210838762037ef03ba4cae3413d931ce387
```

## Data Path

```
# Ground Truth Texts
assets/Language/sense/
# Model-Generated Texts
outputs/
```

## Installation

The requirements are listed in [frozen_requirements.txt](frozen_requirements.txt).  
The code has been tested using `Python 3.8`.  
Run the following for installation:

#### Create a virtual environment
```
cd <path_to_this_project>
conda create -n lang_neuron python=3.8
conda activate lang_neuron
pip install -U pip wheel
```

#### Install selfcond (recommended for reproducibility)
```
bash
pip install -r frozen_requirements.txt
python -c "import nltk; nltk.download('punkt')"
```

-----
## 1. Finding Language-Specific Neurons

Models are fetched from [HuggingFace Transformers repository](https://huggingface.co/transformers/). 
Model Support:
- xglm
- bloom
- llama-2


### 1.1 Collect responses from a model

Run the following script to collect responses from a model when specified texts are entered into the model.

```
bash main_prod_env.sh "xglm-564M compute_responses Language de 2000 on_p50 expertise_limited_2000_both"
```

The responses will be saved inside `path_to_save_responses/{model_name}/sense/[concept]/responses`.

### 1.2 Compute expertise

The expertise is defined as the Average Precision (AP) achieved by a unit when its responses are considered prediction scores for the sentences.

```
bash main_prod_env.sh "xglm-564M compute_expertise Language de 2000 on_p50 expertise_limited_2000_both"
```

The expertise results are saved as a CSV file in `path_to_save_responses/{model_name}/sense/[concept]/expertise`.
Column `ap` contains the expertise measured for each model unit and column `on_p50` contains the median response of each unit to the positive sentences. 

### 1.3 Limit expertise (only Top-N and Bottom-N neurons)

Run the following script to to limit expertise to only Top-N and Bottom-N neurons.

```
bash main_prod_env.sh "xglm-564M limit_expertise Language de 2000 on_p50 expertise_limited_2000_both"
```

## 2. Controlling Language-Specific Neurons

### 2-1. Unconditional text generation

In this step, the above computed expertise is used to generate sentences starting with a null prompt.

```
bash main_prod_env.sh "xglm-564M generate_activated Language de 2000 on_p50 expertise_limited_2000_both"
```

### 2-2. Conditional text generation (machine translation task)

In this step, the above computed expertise is used to generate sentences with a prompt "Translate an English sentence into a target language.\nEnglish: {source_text}\nTarget Language:".

```
bash main_prod_env.sh "xglm-564M generate_activated_condition Language de 2000 on_p50 expertise_limited_2000_both flores200 2"
```
