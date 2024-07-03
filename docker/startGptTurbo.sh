# 搭建Chat-GPT
# https://doc.muluhub.com/docs/gpt4turbo
# apiKey -> https://openai-hk.com/


docker run -it -d \
--name chatgpt-next-web \
-d -p 1210:3000 --restart=always \
-e OPENAI_API_KEY=hk-thxoi910000098697c5e56182da63aeafa082b417a7895d0 \
-e CODE= \
-e HIDE_USER_API_KEY=1 \
-e BASE_URL=https://api.openai-hk.com \
yidadaa/chatgpt-next-web