#! /bin/bash
auth_name=$1
harbor_host=$2
auth_address=$3
auth_user=$4
auth_password=$5
auth_status=false
echo '参数依次对应认证名称(示例:wise2c auth)、
      harbor ui所在主机地址(示例:http://121.40.232.99)、
      认证地址(示例:http://121.40.232.51)、
      认证用户名(示例:wise2c@wise2c.com)、
      认证密码(示例:wise2c)'

if [[ $auth_name = '' || $harbor_host = '' || $auth_address = '' || $auth_user = '' || $auth_password = '' ]]; then
    echo '输入参数有误'
    exit
fi

echo '==== 开始生成配置文件 ===='
cd make && ./prepare

# 启动容器
cd dev && docker-compose up -d

function config_input() {
    read -p "请输入认证名称(示例:wise2c auth):" auth_name
    read -p "请输入harbor ui所在主机地址(示例:http://121.40.232.99):" harbor_host
    read -p "请输入认证地址(示例:http://121.40.232.51):" auth_address
    read -p "请输入认证用户名(示例:wise2c@wise2c.com):" auth_user
    read -p "请输入认证密码(示例:wise2c):" auth_password
#    auth_name='wise2c'
#    harbor_host='http://120.26.207.37'
#    auth_address='http://121.40.232.51:31112' #'http://121.40.232.51:31112'
#    auth_user='admin@wise2c.com'
#    auth_password='wise2c2017'
}

# 添加认证管理
# Method: POST
# API:$harbor_host/api/v1/authentications
# {
#  "name":"auth info",  //必填
#  "address":"http://192.168.31.91", //认证地址  必填
#  "username":"admin@wise2c.com",
#  "password":"password",
#  "description":""  //选填
# }
function authentication () {
    echo "$harbor_host/api/v1/authentications"
    result=`curl -i \
            -H "Content-Type: application/json" \
            -X POST -d "{\"name\":\"$auth_name\", \"address\":\"$auth_address\", \"username\":\"$auth_user\", \"password\":\"$auth_password\"}" \
            $harbor_host/api/v1/authentications`

     length=`echo ${result} | grep '200 OK' | wc -l`
    if [ $length -gt 0 ];then
	auth_status=true
        echo '认证添成功'
    else
	auth_status=false
        echo '认证添加失败'
    fi
}

# 验证认证信息是否有效
# Method: GET
# API:$harbor_host/api/v1/authentications/validate
# 验证认证管理地址是否有效, 间隔调用该函数, 成功直接退出。一直没成功可以设定20分钟后还是失败就中断
function auth_validate () {
   if [ $auth_status = false ];then
     echo '认证地址不合法请确认,认证信息添加正确'
     exit 0
   fi
   
   result=$(curl $harbor_host/api/v1/authentications/validate | jq .enable)
   if [ $result = true ];then
       echo '认证通过'
       exit 1
   else
       echo '认证不可用'
   fi
}

function do_validate () {
    start=`date '+%s'`
    duration=0
    while (( duration < 30*60 ))
    do
        current=`date '+%s'`
        duration=$(($current-$start))
        auth_validate
        sleep 20s
    done
}

#config_input
authentication
do_validate

