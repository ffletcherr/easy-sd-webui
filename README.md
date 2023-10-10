# easy-sd-webui
bash scripts that set up Automatic1111 SD WebUI

## If you are a root user

```
apt-get update
apt install sudo
passwd  # is useful when use runpod PyTorch Jupyter
adduser [USERNAME]
sudo usermod -aG sudo [USERNAME]
su [USERNAME]

# if you got permission error:
sudo chmod -R 777 .
```
