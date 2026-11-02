import os, pty, re, select, sys, time

argv = sys.argv[1:]
sep = argv.index("--")
cmd, keys = argv[:sep], argv[sep + 1:]

pid, fd = pty.fork()
if pid == 0:
    os.execv(cmd[0], cmd)

out = b""


def drain(seconds):
    global out
    end = time.time() + seconds
    while time.time() < end:
        ready, _, _ = select.select([fd], [], [], 0.1)
        if ready:
            try:
                out += os.read(fd, 65536)
            except OSError:
                return


drain(2.5)
for k in keys:
    os.write(fd, k.encode().decode("unicode_escape").encode())
    drain(2)
drain(1)
print(re.sub(r"\x1b\[[0-9;?]*[A-Za-z]", "", out.decode("utf-8", "replace")))
