#!/bin/bash

# 定義實例 ID 和區域
INSTANCE_ID="i-0798b3169bb8c6e13"
REGION="us-east-1"
AWS_PROFILE_NAME="gl2"

# 設定 AWS CLI 使用的 Profile
export AWS_PROFILE="$AWS_PROFILE_NAME"

# 使用 AWS CLI 啟動實例，並指定區域
aws ec2 start-instances --instance-ids "$INSTANCE_ID" --region "$REGION"

# 確認啟動狀態
if [ $? -eq 0 ]; then
    echo "實例 $INSTANCE_ID 已啟動於區域 $REGION。"

    # 等待實例狀態為 running
    echo "等待實例啟動完成..."
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"

    # 取得公有 IP (若需要私有 IP，請修改 query)
    PUBLIC_IP=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --region "$REGION" \
        --query "Reservations[].Instances[].PublicIpAddress" \
        --output text)

    if [ -n "$PUBLIC_IP" ]; then
        echo "實例的公有 IP 是: $PUBLIC_IP"
    else
        echo "無法取得公有 IP，可能尚未分配。"
    fi
else
    echo "無法啟動實例 $INSTANCE_ID，請檢查錯誤訊息。"
fi

