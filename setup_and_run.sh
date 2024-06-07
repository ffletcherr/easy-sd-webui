# cd to the parent directory of this file before running it
absolute_path=$(realpath $0)
absolute_dir=$(dirname $absolute_path)
parent_dir=$(dirname $absolute_dir)
cd $parent_dir
# check if stable-diffusion-webui folder exists
if [ -d "stable-diffusion-webui" ]; then
    echo "[INFO] stable-diffusion-webui folder already exists"
    echo "[INFO] just running webui.sh"
    cd stable-diffusion-webui
    bash webui.sh
    exit 0
fi
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
    https://civitai.com/api/download/models/274039
    https://civitai.com/api/download/models/471120
    https://civitai.com/api/download/models/501240
)
sd_model_names=(
    juggernaut_reborn.safetensors
    Juggernaut_X_RunDiffusion_Hyper.safetensors
    realisticVisionV60B1_v51HyperVAE.safetensors
)
for (( i=0; i<${#sd_model_urls[*]}; ++i)); do
    download_model ${sd_model_urls[$i]} ${sd_model_names[$i]} models/Stable-diffusion
done


# loop over repos to clone
extensions_repos=(
    https://github.com/Mikubill/sd-webui-controlnet.git
    https://github.com/Vetchems/sd-civitai-browser.git
    https://github.com/Bing-su/adetailer.git
)
for repo_url in "${extensions_repos[@]}"
do
    clone_repo $repo_url
done

# download motion models
motion_model_urls=(
    https://huggingface.co/guoyww/animatediff/resolve/refs%2Fpr%2F3/mm_sd_v15_v2.safetensors
)
motion_model_names=(
    mm_sd_v15_v2.safetensors
)
for (( i=0; i<${#motion_model_urls[*]}; ++i)); do
    download_model ${motion_model_urls[$i]} ${motion_model_names[$i]} extensions/sd-webui-animatediff/model

done
# loop over models to download
controlnet_model_urls=(
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_lineart.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_softedge.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1p_sd15_depth.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.pth
    https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sd15.bin
    https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sd15_lora.safetensors
    https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl.bin
    https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl_lora.safetensors
)
controlnet_model_names=(
    control_v11p_sd15_openpose.pth
    control_v11p_sd15_inpaint.pth
    control_v11p_sd15_canny.pth
    control_v11p_sd15_lineart.pth
    control_v11p_sd15_softedge.pth
    control_v11f1p_sd15_depth.pth
    control_v11f1e_sd15_tile.pth
    ip-adapter-faceid-plusv2_sd15.bin
    ip-adapter-faceid-plusv2_sd15_lora.safetensors
    ip-adapter-faceid-plusv2_sdxl.bin
    ip-adapter-faceid-plusv2_sdxl_lora.safetensors
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
    'Detail_Tweaker_XL.safetensors'
    'Add_More_Details_Detail_Enhancer.safetensors'
    'Detail_Tweaker.safetensors'
)
for (( i=0; i<${#lora_model_urls[*]}; ++i)); do
    download_model ${lora_model_urls[$i]} ${lora_model_names[$i]} models/Lora
done

embd_model_urls=(
    https://civitai.com/api/download/models/60938
    https://civitai.com/api/download/models/149308
)
embd_model_names=(
    'negative_hand.pt'
    'unaestheticXL_XL.safetensors'
)
for (( i=0; i<${#lora_model_urls[*]}; ++i)); do
    download_model ${embd_model_urls[$i]} ${embd_model_names[$i]} embeddings
done

sudo chmod -R 777 .

# if python3.10 is needed:
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.10 -y
sudo apt install python3.10-venv -y

printf '#!/bin/bash\n\nexport COMMANDLINE_ARGS="--api --listen --no-half-vae --enable-insecure-extension-access --port 7869"\n\npython_cmd="python3.10"' > webui-user.sh

bash webui.sh
