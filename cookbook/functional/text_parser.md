
# split magic

there are some super cool tools to get maps out of text

```golang
t:='
_cmiodalassistants   304   0.0  0.0 408185328   1360   ??  S    16Dec23   0:34.06 /usr/sbin/distnoted agent
_locationd         281   0.0  0.0 408185328   1344   ??  S    16Dec23   0:35.80 /usr/sbin/distnoted agent

	root               275   0.0  0.0 408311904   7296   ??  Ss   16Dec23   2:00.56 /usr/libexec/storagekitd
_coreaudiod        268   0.0  0.0 408185328   1344   ??  S    16Dec23   0:35.49 /usr/sbin/distnoted agent
'

r4:=texttools.to_list_map("name,-,-,-,-,pid,-,-,-,-,path",t,"")
assert [{'name': '_cmiodalassistants', 'pid': '1360', 'path': '/usr/sbin/distnoted'}, 
		{'name': '_locationd', 'pid': '1344', 'path': '/usr/sbin/distnoted'}, 
		{'name': 'root', 'pid': '7296', 'path': '/usr/libexec/storagekitd'}, 
		{'name': '_coreaudiod', 'pid': '1344', 'path': '/usr/sbin/distnoted'}] == r4

```