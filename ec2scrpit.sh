#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Get the IMDSv2 token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Background the curl requests
curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4 &> /tmp/local_ipv4 &
curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone &> /tmp/az &
curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/ &> /tmp/macid &
wait

macid=$(cat /tmp/macid)
local_ipv4=$(cat /tmp/local_ipv4)
az=$(cat /tmp/az)
vpc=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${macid}/vpc-id)

echo "
<!doctype html>
<html lang="en" class="h-100">
<head>
<title>Details for EC2 instance</title>
<body background=https://img.freepik.com/premium-photo/flag-wallpaper-brazil_670382-35283.jpg>
</head>
<div>
<font color="ffffff">
<h1>AWS Instance Details</h1>
<h1>Theo's Brazilian Blondes</h1>
</font>
<br>
<table width=100%>
<tr>
<td width=100% align="left">
<img src="https://www.sanclerfrantz.com.br/extranet/gallery/50.jpg" alt="Samurai Katana" width="40%" height="40%">
</td>
</tr>
<tr>
<td width=100% align="left">
<img src="https://images3.imgbox.com/41/12/sIUUCRwA_o.jpg" alt="Sexy Brazilian Blonde" width="40%" height="40%">
</td>
</tr>
</table>
<br>
<font color="ffffff" size="5">
<p><b>Instance Name:</b> $(hostname -f)</p>
<p><b>Instance Private Ip Address:</b> ${local_ipv4}</p>
<p><b>Availability Zone:</b> ${az}</p>
<p><b>Virtual Private Cloud (VPC):</b> ${vpc}</p>
</font>
</div>
</body>
</html>
" > /var/www/html/index.html

# Clean up the temp files
rm -f /tmp/local_ipv4 /tmp/az /tmp/macid