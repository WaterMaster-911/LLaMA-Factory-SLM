#!/bin/bash

# 基础配置文件模板内容
CONFIG_TEMPLATE=$(cat <<EOF
### Note: DO NOT use quantized model or quantization_bit when merging lora adapters

### model
model_name_or_path: /data/wuyong/model/Qwen/Qwen2.5-Math-1.5B
adapter_name_or_path: saves/Qwen2.5-Math-1.5B-long-cot-__STEP__/lora/sft
trust_remote_code: true

### export
export_dir: long_cot_exp/eva_model/Qwen2.5-Math-1.5B-long-cot-__STEP__
export_size: 5
export_device: cpu
export_legacy_format: false
EOF
)

# 循环从 2000 到 20000，每次加 1000
for ((step=1000; step<=4000; step+=1000)); do
    config_file="lenght_exp/export/export_qwen_long_cot_${step}.yaml"
    
    # 替换 __STEP__ 占位符为当前 step 数值并写入配置文件
    echo "$CONFIG_TEMPLATE" | sed "s/__STEP__/${step}/g" > "$config_file"
    
    echo "🔧 正在导出 step: $step"
    llamafactory-cli export "$config_file"
    
    echo "✅ 完成 step: $step"
    echo "--------------------------"
done
