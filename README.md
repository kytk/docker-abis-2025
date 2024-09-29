# Docker ABiS 2025

## クイックスタート

Lin4Neuro環境を起動するには：

```bash
docker run -d -p 6080:6080 \
  --platform linux/amd64 \
  -v /your/host/path:/home/brain/share \
  --name abis-2025 \
  kytk/docker-abis-2025:latest
```

その後、Webブラウザで `http://localhost:6080` にアクセスすると、Lin4Neuroデスクトップ環境を使用できます。

## カスタム解像度

コンテナ起動時にカスタム解像度を指定できます：

```bash
docker run -d -p 6080:6080 \
  --platform linux/amd64 \
  -e RESOLUTION=1920x1080x24 \
  -v /your/host/path:/home/brain/share \
  --name abis-2025 \
  kytk/docker-abis-2025:latest
```

指定しない場合、デフォルトの解像度は1600x900x24です。


## 注意

このDockerイメージは研究および教育目的で提供されています。含まれるソフトウェアパッケージのライセンス条項を遵守してご使用ください。
