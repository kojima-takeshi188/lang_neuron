#------ option --------#

#$ -j y
#$ -m e
#$ -m a
#$ -m b
#$ -cwd

#------- Program execution -------#

# ARGMENTS
echo ${1}
args=(${1})

model_name=${args[0]}
phase=${args[1]}
datapath=${args[2]}
language=${args[3]}
num_units=${args[4]}
force_value=${args[5]}
expert_file=${args[6]}
translation_task=${args[7]}
prompt_format_id_for_translation=${args[8]}

echo ${model_name}
echo ${phase}
echo ${datapath}
echo ${language}
echo ${num_units}
echo ${force_value}
echo ${expert_file}
echo ${translation_task}
echo ${prompt_format_id_for_translation}

# LOGIN CONDA VENV
source ~/.bashrc
conda activate lang_neuron

# MODULE LOAD
module load gcc/8.3.1 gcc/8.5.0 cuda/11.7/11.7.1 cudnn/8.8/8.8.1

# Path setting
model_path="set_appropriate_path_1/"
base_path="set_appropriate_path_2/"

# BOS setting
# xglms: </s> is automatically set.
# bloom: nothing is automatically set. So we explicitly set </s>.
# llama2: <s> is automatically set.
if [[ ${model_name} == *"xglm"* ]]; then
  model_name2="facebook/${model_name}"
  #prompt="</s>"
  prompt=""
elif [[ ${model_name} == *"bloom"* ]]; then
  model_name2="bigscience/${model_name}"
  prompt="</s>"
elif [[ ${model_name} == *"Llama-2"* ]]; then
  model_name2="${model_path}llama2-HF/${model_name}"
  #prompt="<s>"
  prompt=""
else
  echo "NG!"
  exit
fi

if [ ${phase} == "compute_responses" ] || [ ${phase} == "compute_all" ]; then
  python scripts/compute_responses.py --model-name-or-path ${model_name2} --data-path assets/${datapath} --responses-path ${base_path}${datapath} --concepts sense/${language}
fi

if [ ${phase} == "compute_expertise" ] || [ ${phase} == "compute_all" ]; then
  python scripts/compute_expertise.py --root-dir ${base_path}${datapath} --model-name ${model_name2} --concepts assets/${datapath}/${language} --concepts sense/${language}
fi

if [ ${phase} == "limit_expertise" ] || [ ${phase} == "compute_all" ]; then
  python scripts/make_limited_expert_exe.py --model-name ${model_name} --language ${language} --num-units ${num_units}
fi

if [ ${phase} == "generate_activated" ]; then
  python scripts/generate_seq_lang.py --model-name-or-path ${model_name2} --expertise ${base_path}${datapath}/${model_name}/sense/${language}/expertise/${expert_file}.csv --length 64 --seed 1 101 --metric ap --forcing ${force_value} --num-units ${num_units} --eos --top-n 1 --results-file ${base_path}${datapath}/${model_name}/sense/${language}/expertise/created_sentence_${force_value}_${num_units}_${expert_file}.csv --temperature 0.8 --prompt "${prompt}"
fi

if [ ${phase} == "generate_activated_condition" ]; then
  translation_file="assets_translation/translation_text_${translation_task}_en_${language}.pkl"
  python scripts/generate_seq_lang.py --model-name-or-path ${model_name2} --expertise ${base_path}${datapath}/${model_name}/sense/${language}/expertise/${expert_file}.csv --length 128 --seed 1 101 --metric ap --forcing ${force_value} --num-units ${num_units} --eos --top-n 1 --results-file ${base_path}${datapath}/${model_name}/sense/${language}/expertise/created_sentence_${force_value}_${num_units}_${expert_file}_${translation_task}_condition_${prompt_format_id_for_translation}.csv --temperature 0.0 --prompt ${translation_file} --prompt_format_id_for_translation ${prompt_format_id_for_translation}
fi
