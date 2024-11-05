# Docker ABiS 2025

## クイックスタート

Lin4Neuro環境を起動するには：

- 共有するためのディレクトリを作成し、そこにFreeSurferのライセンス、license.txt を保存したうえで、ターミナルから以下を実行してください

```bash
docker run --shm-size=4g -d -p 5901:5901 \
  --platform linux/amd64 \
  -v /your/host/path:/home/brain/share \
  kytk/docker-abis-vnc:latest
```


その後、VNCクライアントで `localhost:5901` にアクセスすると、Lin4Neuroデスクトップ環境を使用できます。

## カスタム解像度

コンテナ起動時にカスタム解像度を指定できます：

```bash
docker run --shm-size=4g -d -p 5901:5901 \
  --platform linux/amd64 \
  -e RESOLUTION=1920x1080 \
  -v /your/host/path:/home/brain/share \
  kytk/docker-abis-vnc:latest
```

指定しない場合、デフォルトの解像度は1600x900x24です。


## 注意

このDockerイメージは研究および教育目的で提供されています。含まれるソフトウェアパッケージのライセンス条項を遵守してご使用ください。
