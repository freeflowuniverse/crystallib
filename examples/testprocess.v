import process

job := process.execute({cmd:"find /", timeout:1, die:false, stdout:false, stdout_log:false}) or {panic(err)}
print(job)


job2 := process.execute({cmd:"find /tmp/", timeout:1}) or {panic(err)}
print(job2)



job3 := process.execute({cmd:"cd / &&ls /", timeout:1}) or {panic(err)}
print(job3)


job4 := process.execute({cmd:"echo \"hi\" > /tmp/a.txt"}) or {panic(err)}
print(job4)