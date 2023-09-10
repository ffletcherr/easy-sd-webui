# check aria2c is installed
if ! command -v aria2c &> /dev/null
then
    sudo apt-get update
    echo "aria2c could not be found"
    echo "installing aria2c"
    sudo apt install aria2 -y
fi

# function to clone extensions repos
function clone_repo {
    repo_url=$1
    repo_name=$(echo $repo_url | sed -e 's/.*\///' -e 's/.git//')
    git clone $repo_url extensions/$repo_name
}

git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui

function download_model {
    model_url=$1
    model_name=$2
    dest_folder=$3
    aria2c --check-certificate=false --console-log-level=error -c -x 16 -s 16 -k 1M $model_url -d $dest_folder -o $model_name
}

# loop over models to download
sd_model_urls=(
    https://huggingface.co/emmajoanne/models/resolve/main/revAnimated_v122.safetensors
    https://civitai.com/api/download/models/156110
    https://civitai.com/api/download/models/156005
    https://civitai.com/api/download/models/126688
    https://civitai.com/api/download/models/128592
)
sd_model_names=(
    revAnimated_v122.safetensors
    Deliberate_v3.safetensors
    juggernautXL_version3.safetensors
    dreamshaperXL10_alpha2Xl10.safetensors
    animeArtDiffusionXL_alpha3.safetensors
)
for (( i=0; i<${#sd_model_urls[*]}; ++i)); do
    download_model ${sd_model_urls[$i]} ${sd_model_names[$i]} models/Stable-diffusion
done


# loop over repos to clone
extensions_repos=(
    https://github.com/Mikubill/sd-webui-controlnet.git
    https://github.com/Vetchems/sd-civitai-browser.git
)
for repo_url in "${extensions_repos[@]}"
do
    clone_repo $repo_url
done

# loop over models to download
controlnet_model_urls=(
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_lineart.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_softedge.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.pth
    https://huggingface.co/ViscoseBean/control_v1p_sd15_brightness/resolve/main/control_v1p_sd15_brightness.safetensors
    https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_mid.safetensors
    https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_depth_mid.safetensors
    https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/ip-adapter_sd15.pth
    https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/ip-adapter_sd15_plus.pth
    https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/ip-adapter_xl.pth
    https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/t2i-adapter_xl_openpose.safetensors
    https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/t2i-adapter_xl_sketch.safetensors
)
controlnet_model_names=(
    control_v11p_sd15_openpose.pth
    control_v11p_sd15_inpaint.pth
    control_v11p_sd15_canny.pth
    control_v11p_sd15_lineart.pth
    control_v11p_sd15_softedge.pth
    control_v11f1e_sd15_tile.pth
    control_v1p_sd15_brightness.safetensors
    diffusers_xl_canny_mid.safetensors
    diffusers_xl_depth_mid.safetensors
    ip-adapter_sd15.pth
    ip-adapter_sd15_plus.pth
    ip-adapter_xl.pth
    t2i-adapter_xl_openpose.safetensors
    t2i-adapter_xl_sketch.safetensors
)
for (( i=0; i<${#controlnet_model_urls[*]}; ++i)); do
    download_model ${controlnet_model_urls[$i]} ${controlnet_model_names[$i]} models/ControlNet
done

lora_model_urls=(
    https://civitai.com/api/download/models/135867
    https://civitai.com/api/download/models/87153
    https://civitai.com/api/download/models/62833
)
lora_model_names=(
    'Detail Tweaker XL'
    'Add More Details - Detail Enhancer'
    'Detail Tweaker LoRA'
)
for (( i=0; i<${#lora_model_urls[*]}; ++i)); do
    download_model ${lora_model_urls[$i]} ${lora_model_names[$i]} models/Lora
done