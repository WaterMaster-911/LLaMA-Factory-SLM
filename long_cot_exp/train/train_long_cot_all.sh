#!/bin/bash
# 此脚本自动更新训练配置中的 dataset 和 output_dir 参数，
# 从 1000 到 20000，每隔 1000 递增，并调用 accelerate 进行训练。

export DISABLE_VERSION_CHECK=1

# 配置变量，可根据需要修改
START=1000
END=4000
STEP=1000

# 原始的 YAML 配置文件（需要保证该文件存在且包含 "dataset:" 和 "output_dir:" 字段）
BASE_CONFIG="long_cot_exp/fsdp_qlora/qwen_math_lora_sft.yaml"

# accelerate 相关配置
ACCELERATE_CONFIG="long_cot_exp/accelerate/fsdp_config_4.yaml"
PORT=6570
GPU_IDS="1,2,3,4"

# 循环更新配置并启动训练
for (( i=$START; i<=$END; i+=$STEP )); do
    # 更新 dataset 与 output_dir 的值
    new_dataset="long_cot_${i}"
    new_output_dir="saves/Qwen2.5-Math-1.5B-long-cot-${i}/lora/sft"
    
    # 生成临时配置文件
    # tmp_config="temp_config_${i}.yaml"
    tmp_config="long_cot_exp/temp_configs/temp_config_${i}.yaml"
    mkdir -p "$(dirname "$tmp_config")"
    cp "$BASE_CONFIG" "$tmp_config"
    
    # 使用 sed 修改配置文件中的 dataset 和 output_dir 字段
    sed -i "s/^dataset: .*/dataset: ${new_dataset}/" "$tmp_config"
    sed -i "s#^output_dir: .*#output_dir: ${new_output_dir}#" "$tmp_config"
    
    echo "开始训练：dataset = ${new_dataset}, output_dir = ${new_output_dir}"
    
    # 调用 accelerate 进行训练
    accelerate launch --gpu_ids $GPU_IDS \
        --config_file "$ACCELERATE_CONFIG" \
        --main_process_port $PORT \
        src/train.py "$tmp_config"
    
    # 训练结束后删除临时配置文件
    # rm "$tmp_config"
done
