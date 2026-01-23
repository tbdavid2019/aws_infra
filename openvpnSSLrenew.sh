#!/bin/bash

# 檢查是否為 root
if [ "$EUID" -ne 0 ]; then 
  echo "請使用 sudo 執行此腳本"
  exit 1
fi

DOMAIN="openvpn.glsoft.ai"
SACLI="/usr/local/openvpn_as/scripts/sacli"

echo "--- 開始更新 SSL 憑證過程 ---"

# 1. 停止 OpenVPN AS 以釋放 Port 80
echo "正在暫時停止 OpenVPN Access Server..."
systemctl stop openvpnas

# 2. 執行 Certbot 更新憑證 (使用 standalone 模式)
echo "正在透過 Certbot 取得新憑證..."
# 使用 --force-renewal 確保即便沒過期也重新取得（或移除此參數僅做 renew）
# 使用 --non-interactive 自動處理
certbot certonly --standalone \
    -d $DOMAIN \
    --non-interactive \
    --agree-tos \
    --register-unsafely-without-email \
    --force-renewal

# 檢查 certbot 是否執行成功
if [ $? -eq 0 ]; then
    echo "憑證取得成功！正在匯入至 OpenVPN AS..."

    # 3. 將憑證匯入至 OpenVPN AS 設定中
    $SACLI --key "cs.priv_key" --value_file "/etc/letsencrypt/live/$DOMAIN/privkey.pem" ConfigPut
    $SACLI --key "cs.cert" --value_file "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ConfigPut
    $SACLI --key "cs.ca_bundle" --value_file "/etc/letsencrypt/live/$DOMAIN/chain.pem" ConfigPut

    echo "憑證匯入完成，正在套用設定並啟動服務..."
    
    # 4. 套用設定並重新啟動
    $SACLI start
    systemctl start openvpnas
    
    echo "--- 憑證更新成功且服務已恢復 ---"
else
    echo "Certbot 執行失敗，請檢查網路或網域解析。正在嘗試重新啟動原始服務..."
    systemctl start openvpnas
    exit 1
fi
