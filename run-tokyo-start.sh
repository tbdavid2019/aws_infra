#!/bin/bash

# 定義實例 ID 和區域
INSTANCE_ID="i-0f694a91348790868"
REGION="ap-northeast-1"

# 使用 AWS CLI 終止實例，並指定區域
aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION

# 確認終止狀態
if [ $? -eq 0 ]; then
    echo "實例 $INSTANCE_ID 已啟動於區域 $REGION。"
else
    echo "無法啟動實例 $INSTANCE_ID，請檢查錯誤訊息。"
fi

