USER=$1
PASSWORD=$2
SERVER=$3
ISO_PATH=$4
ISO_URL="http://$(hostname -I | cut -f2 -d" " | xargs)/$ISO_PATH"
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD remoteimage -s &&\
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD remoteimage -d &&\
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD remoteimage -c -l $ISO_URL &&\
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD set iDRAC.VirtualMedia.BootOnce 1 &&\
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD set iDRAC.ServerBoot.FirstBootDevice VCD-DVD &&\
/opt/dell/srvadmin/bin/idracadm7 -r $SERVER -u $USER -p $PASSWORD serveraction powercycle
