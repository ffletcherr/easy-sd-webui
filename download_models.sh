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

# function to download sd models from huggingface
function download_model {
    model_url=$1
    model_name=$(echo $model_url | sed -e 's/.*\///')
    aria2c --check-certificate=false --console-log-level=error -c -x 16 -s 16 -k 1M $model_url -d models/Stable-diffusion -o $model_name
}

# loop over models to download
sd_model_urls=(
    # https://huggingface.co/XpucT/Deliberate/resolve/main/Deliberate_v2.safetensors
    'https://civitai.com/api/download/models/156110?type=Model&format=SafeTensor&size=full&fp=fp16'
    https://huggingface.co/emmajoanne/models/resolve/main/revAnimated_v122.safetensors
    # Juggernaut XL Version 3
    https://civitai.com/api/download/models/156005
)

for model_url in "${sd_model_urls[@]}"
do
    download_model $model_url
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

# function to download controlnet models from huggingface
function download_model {
    model_url=$1
    model_name=$(echo $model_url | sed -e 's/.*\///')
    aria2c --check-certificate=false --console-log-level=error -c -x 16 -s 16 -k 1M $model_url -d extensions/sd-webui-controlnet/models -o $model_name
}
# loop over models to download
controlnet_model_urls=(
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_lineart.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_softedge.pth
    https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.pth
    https://huggingface.co/ViscoseBean/control_v1p_sd15_brightness/resolve/main/control_v1p_sd15_brightness.safetensors
)
for model_url in "${controlnet_model_urls[@]}"
do
    download_model $model_url
done

# function to download LoRAs models from CivitAI
function download_model {
    model_url=$1
    model_name=$(echo $model_url | sed -e 's/.*\///')
    aria2c --check-certificate=false --console-log-level=error -c -x 16 -s 16 -k 1M $model_url -d models/Lora/models -o $model_name
}

lora_model_urls =(
    https://civitai.com/api/download/models/135867
)